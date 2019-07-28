/* SCALING ---------------------------------------*/

variable "count" {
  description = "Number of hosts to run."
}

variable "type" {
  description = "Type of machine to deploy."

  /* https://cloud.google.com/compute/docs/machine-types */
  default = "n1-standard-1"
}

variable "vol_size" {
  description = "Size of the base image."

  /* 0 should default to size of base image */
  default = 10
}

variable "zone" {
  description = "Specific zone in which to deploy hosts."

  /* https://cloud.google.com/compute/docs/regions-zones/ */
  default = "us-central1-a"
}

variable "image" {
  description = "OS image to use when deploying hosts."

  /* https://cloud.google.com/compute/docs/images */
  default = "ubuntu-os-cloud/ubuntu-1804-lts"
}

variable "provider" {
  description = "Short name of the provider used."

  /* Google Cloud */
  default = "gc"
}

/* CONFIG ----------------------------------------*/

variable "name" {
  description = "Name for hosts. To be used in the DNS entry."
  default     = "node"
}

variable "env" {
  description = "Environment for these hosts, affects DNS entries."
}

variable "group" {
  description = "Ansible group to assign hosts to."
}

variable "domain" {
  description = "DNS Domain to update"
}

/* MODULE ----------------------------------------*/

variable "ssh_user" {
  description = "User used to log in to instance"
  default     = "root"
}

variable "ssh_key" {
  description = "Names of ssh public keys to add to created hosts"

  /* TODO this needs to be dynamic */
  default = "~/.ssh/status.im/id_rsa.pub"
}

/* FIREWALL -------------------------------------------*/

variable "open_ports" {
  description = "Port ranges to enable access from outside. Format: 'N-N'"
  type        = list(string)
  default     = []
}

/* See: https://www.terraform.io/docs/providers/google/r/compute_firewall.html */
variable "blocked_ips" {
  description = "List of source IP ranges for which we want to block access."
  type        = list(string)
  default     = []
}

