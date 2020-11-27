/* DERIVED --------------------------------------*/

locals {
  stage = var.stage != "" ? var.stage : terraform.workspace
  dc    = "${var.provider_name}-${var.zone}"
  /* always add SSH, Tinc, Netdata, and Consul to allowed ports */
  open_tcp_ports = concat(["22", "655", "8000", "8301"], var.open_tcp_ports)
  open_udp_ports = concat(["655", "8301"], var.open_udp_ports)
  /* tags applied to theinstances */
  tags = [
    var.name, local.stage, var.env,
    "${var.name}-${var.env}-${local.stage}",
  ]
  tags_sorted = sort(distinct(local.tags))
  /* pre-generated list of hostnames */
  hostnames = [for i in range(1, var.host_count+1): 
    "${var.name}-${format("%02d", i)}.${local.dc}.${var.env}.${local.stage}"
  ]
}

/* RESOURCES ------------------------------------*/

resource "google_compute_address" "host" {
  name   = replace(local.hostnames[count.index], ".", "-")
  region = substr(var.zone, 0, length(var.zone)-2) /* WARNING: Dirty but works */
  count  = var.host_count
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_firewall" "host" {
  name        = "allow-${var.name}-${var.zone}-${var.env}-${local.stage}"
  network     = "default"
  target_tags = ["${var.name}-${var.env}-${local.stage}"]

  allow {
    protocol = "tcp"
    ports = local.open_tcp_ports
  }
  allow {
    protocol = "udp"
    ports = local.open_udp_ports
  }
}

/* optional DDoS mitigation by blocking IP ranges */
resource "google_compute_firewall" "deny" {
  name          = "deny-${var.name}-${var.zone}-${var.env}-${local.stage}"
  network       = "default"
  target_tags   = ["${var.name}-${var.env}-${local.stage}"]
  source_ranges = var.blocked_ips

  /* Optional */
  count = length(var.blocked_ips) > 0 ? 1 : 0

  deny {
    protocol = "tcp"
  }
  deny {
    protocol = "udp"
  }
}

resource "google_compute_disk" "host" {
  name  = "data-${replace(local.hostnames[count.index], ".", "-")}"
  type  = var.data_vol_type
  zone  = var.zone
  size  = var.data_vol_size
  count = var.data_vol_size > 0 ? var.host_count : 0

  lifecycle {
    prevent_destroy = true
    /* We do this to avoid destrying a volume unnecesarily */
    ignore_changes = [ name ]
  }
}

resource "google_compute_instance" "host" {
  name     = replace(local.hostnames[count.index], ".", "-")
  hostname = "${local.hostnames[count.index]}.${var.domain}"

  /* scaling */
  zone         = var.zone
  count        = var.host_count
  machine_type = var.type

  /* enable changing machine_type */
  allow_stopping_for_update = true

  tags = local.tags_sorted

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.root_vol_size
      type  = var.root_vol_type
    }
  }

  dynamic "attached_disk" {
    for_each = var.data_vol_size > 0 ? [ google_compute_disk.host[0] ] : []
    content {
      device_name = google_compute_disk.host[count.index].name
      source      = google_compute_disk.host[count.index].self_link
    }
  }

  /* Ignore changes to size of boot_disk */
  lifecycle {
    ignore_changes = [ boot_disk, hostname ]
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.host[count.index].address
    }
  }

  metadata = {
    node  = var.name
    env   = var.env
    group = var.group
    /* This is a hack because we can't use dots in actual instance name */
    hostname = local.hostnames[count.index]
    /* Enable SSH access */
    sshKeys = "${var.ssh_user}:${file(var.ssh_key)}"
    /* Run PowerShell script for initial setup of a Window machine */
    sysprep-specialize-script-ps1 = (var.win_password == null ? null :
      templatefile("${path.module}/setup.ps1", {
        password = var.win_password
        ssh_key  = file(var.ssh_key)
      }))
  }

  /* bootstrap access to host and basic resources */
  provisioner "ansible" {
    plays {
      playbook { file_path = var.ansible_playbook }

      hosts  = [self.network_interface.0.access_config.0.nat_ip]
      groups = [var.group]

      extra_vars = {
        hostname     = local.hostnames[count.index]
        ansible_host = google_compute_address.host[count.index].address
        data_center  = local.dc
        stage        = local.stage
        env          = var.env
        /* Depend on OS, windows requires different settings */
        ansible_ssh_user      = (var.win_password == null ? var.ssh_user : "Administrator")
        ansible_shell_type    = (var.win_password == null ? "sh" : "powershell")
        ansible_become_user   = (var.win_password == null ? null : "Administrator")
        ansible_become_method = (var.win_password == null ? null : "runas")
      }
    }
  }
}

resource "cloudflare_record" "host" {
  zone_id = var.cf_zone_id
  count   = var.host_count
  name    = google_compute_instance.host[count.index].metadata.hostname
  value   = google_compute_instance.host[count.index].network_interface.0.access_config.0.nat_ip
  type    = "A"
  ttl     = 3600
}

resource "ansible_host" "host" {
  inventory_hostname = google_compute_instance.host[count.index].metadata.hostname

  groups = [var.group, local.dc]
  count  = var.host_count

  vars = {
    ansible_user = "admin"
    ansible_host = google_compute_instance.host[count.index].network_interface.0.access_config.0.nat_ip
    hostname     = google_compute_instance.host[count.index].metadata.hostname
    region       = google_compute_instance.host[count.index].zone
    dns_entry    = "${google_compute_instance.host[count.index].metadata.hostname}.${var.domain}"
    data_center  = local.dc
    stage        = local.stage
    env          = var.env
    /* Windows specific settings */
    ansible_shell_type    = (var.win_password == null ? null : "powershell")
    ansible_become_user   = (var.win_password == null ? null : "admin")
    ansible_become_method = (var.win_password == null ? null : "runas")
  }
}

