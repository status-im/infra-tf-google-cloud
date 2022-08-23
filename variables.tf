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
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5NIT2SVFFjV+ZraPBES45z8wkJf769P7AXdZ4FiJw+DcXKawNJCUefeBQY5GVofVOzOHUrkYLqzxVJihIZJaDgeyME/4pLXYztkk9EOWdQSadxLJjWItMJULJrh5nnXzKxv5yy1SGJCTcMSXrvR6JRduu+KTHGncXJ2Ze6Bdgm63sOdfyPCITSC+nc4GexYLAQmBxXCwtKieqfWVmKpazlVDxAg3Q1h2UXOuLTjkWomvzVCggwhzHtN/STQMCH49PlW/VoIBlrpYqlmRGObsdBae4Bk/D5ZpisJi6w573RcF9q3VrqJTHLiSpntfVJEtsbmyiNNckIujQfRk2KYvSCK2iGP17hfCE9HmEfSZNWrKrMqKJ7gHOhXHJrszh6TtN9zmgomPvYolJBLz/2/JC8swfixHPMzxQa+P2NyqC0yWg8Xqd1JLWKLHsLwpEYvmOfyYIY8zOfk7y3OJX8h7D/fgbnG/V75EVuZDc8sqXTJpj3esoEsz8XVu9cVraAOodG4zYKFnoTomAzBJtImh6ghSEDGT5BAvDyFySyJGMibCsG5DwaLvZUcijEkKke7Z7OoJR4qp0JABhbFn0efd/XGo2ZyGtJsibSW7ugayibEK7bDaYAW3lNXgpcDqpBiDcJVQG/UhhCSSrTsG0IUSbvSsrDuF6gCJWVKt4+klvLw== jakub@status.im",
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

