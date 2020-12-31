/* DNS ------------------------------------------*/

/* We default to: statusim.net */
variable "cf_zone_id" {
  description = "ID of CloudFlare zone for host record."
  type        = string
  default     = "14660d10344c9898521c4ba49789f563"
}

/* SCALING ---------------------------------------*/

variable "host_count" {
  description = "Number of hosts to run."
  type        = number
}

/* https://cloud.google.com/compute/docs/machine-types
 * Use: `gcloud compute machine-types list --filter="zone=us-central1-a"` */
variable "type" {
  description = "Type of machine to deploy."
  type        = string
  default     = "n1-standard-1"
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

/* Use: gcloud compute disk-types list */
variable "data_vol_type" {
  description = "Type of the extra data volume."
  type        = string
  default     = "pd-balanced"
}

variable "data_vol_size" {
  description = "Size of the extra data volume."
  type        = number
  default     = 0
}

/* https://cloud.google.com/compute/docs/regions-zones/
 * Use: `gcloud compute zones list` */
variable "zone" {
  description = "Specific zone in which to deploy hosts."
  type        = string
  default     = "us-central1-a"
}

/* Use: 'gcloud compute images list --filter=ubuntu' */
variable "image" {
  description = "OS image to use when deploying hosts."
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
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

variable "ssh_key" {
  description = "Names of ssh public keys to add to created hosts"
  type        = string
  default     = "~/.ssh/status.im/id_rsa.pub" /* TODO this needs to be dynamic */
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

/* See: https://www.terraform.io/docs/providers/google/r/compute_firewall.html */
variable "blocked_ips" {
  description = "List of source IP ranges for which we want to block access."
  type        = list(string)
  default     = []
}

