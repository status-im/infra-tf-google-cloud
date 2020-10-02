locals {
  public_ips = google_compute_instance.host.*.network_interface.0.access_config.0.nat_ip
}

output "public_ips" {
  value = local.public_ips
}

output "hostnames" {
  value = local.hostnames
}

output "hosts" {
  value = zipmap(local.hostnames, local.public_ips)
}
