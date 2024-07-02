/* DERIVED --------------------------------------*/

locals {
  stage = var.stage != "" ? var.stage : terraform.workspace
  dc    = "${var.provider_name}-${var.zone}"
  /* always add SSH, WireGuard, and Consul to allowed ports */
  open_tcp_ports = concat(["22", "8301"], var.open_tcp_ports)
  open_udp_ports = concat(["51820", "8301"], var.open_udp_ports)
  /* tags applied to theinstances */
  tags = [
    var.name, local.stage, var.env,
    "${var.name}-${var.env}-${local.stage}",
  ]
  tags_sorted = sort(distinct(local.tags))
  /* pre-generated list of hostnames */
  hostnames = [for i in range(1, var.host_count + 1) :
    "${var.name}-${format("%02d", i)}.${local.dc}.${var.env}.${local.stage}"
  ]
}

/* RESOURCES ------------------------------------*/

resource "google_compute_address" "host" {
  for_each = toset(local.hostnames)

  name   = replace(each.key, ".", "-")
  region = substr(var.zone, 0, length(var.zone) - 2) /* WARNING: Dirty but works */

  lifecycle {
    prevent_destroy = true
    ignore_changes = [name]
  }
}

resource "google_compute_firewall" "host" {
  name    = "allow-${var.name}-${var.zone}-${var.env}-${local.stage}"
  network = "default"

  target_tags   = ["${var.name}-${var.env}-${local.stage}"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = local.open_tcp_ports
  }
  allow {
    protocol = "udp"
    ports    = local.open_udp_ports
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
  for_each = toset([ for h in local.hostnames : h if var.data_vol_size > 0 ])

  name = "data-${replace(each.key, ".", "-")}"
  type = var.data_vol_type
  zone = var.zone
  size = var.data_vol_size

  lifecycle {
    prevent_destroy = true
    /* We do this to avoid destrying a volume unnecesarily */
    ignore_changes = [name]
  }
}

resource "google_compute_instance" "host" {
  for_each = toset(local.hostnames)

  name     = replace(each.key, ".", "-")
  hostname = each.key

  /* scaling */
  zone         = var.zone
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
    for_each = {
      for k,v in google_compute_disk.host :
        k => v if k == each.key
    }
    content {
      device_name = attached_disk.value.name
      source      = attached_disk.value.self_link
    }
  }

  /* Ignore changes to size of boot_disk */
  lifecycle {
    ignore_changes = [boot_disk, hostname]
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.host[each.key].address
    }
  }

  metadata = {
    dns_entry = "${each.key}.${var.domain}"
    hostname  = each.key
    node      = var.name
    env       = var.env
    group     = var.group
    /* Enable SSH access */
    ssh-keys = join("\n", [for key in var.ssh_keys : "${var.ssh_user}:${key}"])
    /* Run PowerShell script for initial setup of a Window machine */
    sysprep-specialize-script-ps1 = (var.win_password == null ? null :
      templatefile("${path.module}/setup.ps1", {
        hostname = each.key
        domain   = var.domain
        password = var.win_password
        ssh_key  = var.ssh_keys[0]
      })
    )

    /* Allow debugging via `connect-to-serial-port`. */
    serial-port-enable = true
  }
}

resource "null_resource" "host" {
  for_each = google_compute_instance.host

  /* Trigger bootstrapping on host or public IP change. */
  triggers = {
    instance_id = each.value.id
    address_id  = google_compute_address.host[each.key].id
  }

  /* Make sure everything is in place before bootstrapping. */
  depends_on = [
    google_compute_instance.host,
    google_compute_address.host,
    google_compute_disk.host,
  ]

  /* bootstrap access to host and basic resources */
  provisioner "ansible" {
    plays {
      playbook { file_path = var.ansible_playbook }

      hosts  = [each.value.network_interface.0.access_config.0.nat_ip]
      groups = [var.group]

      extra_vars = {
        hostname     = each.key
        ansible_host = google_compute_address.host[each.key].address
        data_center  = local.dc
        stage        = local.stage
        env          = var.env
        /* Depend on OS, windows requires different settings */
        ansible_user          = (var.win_password == null ? var.ssh_user : "Administrator")
        ansible_shell_type    = (var.win_password == null ? "sh" : "powershell")
        ansible_become        = (var.win_password == null ? null : "false")
        ansible_become_method = (var.win_password == null ? null : "runas")
      }
    }
  }
}

resource "cloudflare_record" "host" {
  for_each = google_compute_instance.host

  zone_id = var.cf_zone_id
  name    = each.value.metadata.hostname
  value   = each.value.network_interface.0.access_config.0.nat_ip
  type    = "A"
  ttl     = 3600
}

resource "ansible_host" "host" {
  for_each = google_compute_instance.host

  inventory_hostname = each.key

  groups = ["${var.env}.${local.stage}", var.group, local.dc]

  vars = {
    ansible_host = each.value.network_interface.0.access_config.0.nat_ip
    hostname     = each.key
    region       = each.value.zone
    dns_entry    = each.value.metadata.dns_entry
    data_center  = local.dc
    stage        = local.stage
    env          = var.env
    /* Windows specific settings */
    ansible_shell_type    = (var.win_password == null ? null : "powershell")
    ansible_become_user   = (var.win_password == null ? null : "admin")
    ansible_become_method = (var.win_password == null ? null : "runas")
  }
}

