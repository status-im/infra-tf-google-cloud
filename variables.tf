/* DNS ------------------------------------------*/

variable "cf_zone_id" {
  description = "ID of CloudFlare zone for host record."
  type        = string
  default     = "14660d10344c9898521c4ba49789f563" /* statusim.net */
}

/* SCALING ---------------------------------------*/

variable "host_count" {
  description = "Number of hosts to run."
  type        = number
}

variable "type" {
  description = "Type of machine to deploy."
  type        = string
  default     = "n1-standard-1"
  /* cmd: `gcloud compute machine-types list --filter="zone=us-central1-a"` */
}

variable "root_vol_size" {
  description = "Size of the base image."
  type        = number
  default     = 10 /* 0 should default to size of base image */
}

variable "root_vol_type" {
  description = "Size of the base image."
  type        = string
  default     = "pd-standard"
}

variable "data_vol_type" {
  description = "Type of the extra data volume."
  type        = string
  default     = "pd-balanced"
  /* Use: gcloud compute disk-types list */
}

variable "data_vol_size" {
  description = "Size of the extra data volume."
  type        = number
  default     = 0
}

variable "zone" {
  description = "Specific zone in which to deploy hosts."
  type        = string
  default     = "us-central1-a"
  /* cmd: `gcloud compute zones list` */
}

variable "image" {
  description = "OS image to use when deploying hosts."
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
  /* cmd: `gcloud compute images list --filter=ubuntu` */
}

variable "provider_name" {
  description = "Short name of the provider used."
  type        = string
  default     = "gc" /* Google Cloud */
}

/* CONFIG ----------------------------------------*/

variable "name" {
  description = "Name for hosts. To be used in the DNS entry."
  type        = string
  default     = "node"
}

variable "env" {
  description = "Environment for these hosts, affects DNS entries."
  type        = string
}

variable "stage" {
  description = "Name of stage, like prod, dev, or staging."
  type        = string
  default     = ""
}

variable "group" {
  description = "Ansible group to assign hosts to."
  type        = string
}

variable "domain" {
  description = "DNS Domain to update"
  type        = string
}

/* SECURITY --------------------------------------*/

variable "ansible_playbook" {
  description = "Location of the ansible playbook to run."
  type        = string
  default     = "./ansible/bootstrap.yml"
}

variable "ssh_user" {
  description = "User used to log in to instance"
  type        = string
  default     = "root"
}

variable "ssh_keys" {
  description = "Names of ssh public keys to add to root user of created hosts"
  type        = list(string)
  default = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeWB4SeXQfEsfkNPOkSLoTQ/7VDpf8CsaRQ+waCHEEv4v2fFc/9lMbQ6Z208UEQKJMOMdtwd3eB7j6aFIirMQTYcm/NuxPLdRRnlxLNJIVMBfKUV5V3OkbneqzBTEvtAaIDC506kIlXxAPfZCDVxzAi7B+NkHUvhjCEjScM2KfamahDZUbj2ww2Q/82P1Qj8QY/1b2wC6OXBnKPUQIzAzrxDNYWaXdB/4DysDcib50kd2URenpMVU1DCjSWXBniSnpEVh0Lxjehsnfg+oE3BP3u6wA+1xufukH9h9eQ/hTM1PXEVC2ObpgESRYxc3rqkqVxYbOzrmCRVJpvKoGs+W89vIoFUt6/tzunAMogo2VHhT7LnGE4iizj9YODxIdpRMGGeMgZiceoOuNFAjKg8Qay4aoE50uklim4ircOXgrAasRotUcz28EU5oaV9/NO+GKNzooRNBX2U/c1MsTI+6mz7ppMq0NCHOpO5sY1qC8F2lZbDDGQgC25btqu+xnbqHwCDSst2Sy5yvF3C34F/Xt8kw3zkraB1OmTWwW/QIA+o3AViaA59r+ZicIIEWvUbUbcMD/GFDesOgzK8V9G6kZNuQoEVsq9FHEMTpsGSBDOIHn4aWP+7gQK2FhvyXBGj/z/NDFY1H+I2KvhI0rkV3NaTtUy0+51uKO5Efnx8cQyw== jakub@status.im",
  ]
}

variable "win_password" {
  description = "Password for the windows user."
  type        = string
  default     = null
}

/* FIREWALL --------------------------------------*/

variable "open_tcp_ports" {
  description = "TCP port ranges to enable access from outside. Format: 'N-N'"
  type        = list(string)
  default     = []
}

variable "open_udp_ports" {
  description = "UDP port ranges to enable access from outside. Format: 'N-N'"
  type        = list(string)
  default     = []
}

variable "blocked_ips" {
  description = "List of source IP ranges for which we want to block access."
  type        = list(string)
  default     = []
  /* See: https://www.terraform.io/docs/providers/google/r/compute_firewall.html */
}

