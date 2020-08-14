/* DERIVED --------------------------------------*/

locals {
  stage = terraform.workspace
  dc    = "${var.provider_name}-${var.zone}"
  /* always add SSH, Tinc, Netdata, and Consul to allowed ports */
  open_tcp_ports = concat(["22", "655", "8000", "8301"], var.open_tcp_ports)
  open_udp_ports = concat(["655", "8301"], var.open_udp_ports)

  tags = [
    var.name, local.stage, var.env,
    "${var.name}-${var.env}-${local.stage}",
  ]
  tags_sorted = sort(distinct(local.tags))
}

/* RESOURCES ------------------------------------*/

resource "google_compute_address" "host" {
  name  = "${var.name}-${format("%02d", count.index + 1)}-${local.dc}-${var.env}-${local.stage}"
  count = var.host_count
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
  name  = "data-${var.name}-${format("%02d", count.index + 1)}-${local.dc}-${var.env}-${local.stage}"
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
  name  = "${var.name}-${format("%02d", count.index + 1)}-${local.dc}-${var.env}-${local.stage}"
  zone  = var.zone
  count = var.host_count

  machine_type     = var.type

  /* enable changing machine_type */
  allow_stopping_for_update = true

  tags = local.tags_sorted

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.vol_size
    }
  }

  /* Ignore changes to size of boot_disk */
  lifecycle {
    ignore_changes = [ boot_disk ]
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
    hostname = "${var.name}-${format("%02d", count.index + 1)}.${local.dc}.${var.env}.${local.stage}"
    /* Enable SSH access */
    sshKeys = "${var.ssh_user}:${file(var.ssh_key)}"
  }

  /* bootstrap access to host and basic resources */
  provisioner "ansible" {
    plays {
      playbook {
        file_path = "${path.cwd}/ansible/bootstrap.yml"
      }

      hosts  = [self.network_interface.0.access_config.0.nat_ip]
      groups = [var.group]

      extra_vars = {
        hostname         = "${var.name}-${format("%02d", count.index + 1)}.${local.dc}.${var.env}.${local.stage}"
        ansible_host     = google_compute_address.host[count.index].address
        ansible_ssh_user = var.ssh_user
        data_center      = local.dc
        stage            = local.stage
        env              = var.env
      }
    }
  }
}

resource "google_compute_attached_disk" "host" {
  disk     = google_compute_disk.host[count.index].id
  instance = google_compute_instance.host[count.index].id
  count    = var.data_vol_size > 0 ? var.host_count : 0
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
  }
}

