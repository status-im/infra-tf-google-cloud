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
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
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
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDA6mutbRHO8VvZ61MYvjIVv1Re9NiJGE1piTQq4IFwXOvAi1HkXkMlsjmzYt+CEv0HmMGCHmdrw5xpqnDTWg18lM5RYLzrAv9hBOQ10IC+8FH2XWDKoyz+PBQsNEbbJ23QQtu0O5mpsOzI/KBT9CkiYUYlEBwHI0vNqsdHDLwv3Yt7PhauguXDHpYnwH/OseVHLBg2+/3aJIfOMVVRnhptQGYAhTNUZ9F1EwvQETMhM/vEsk8+o9B3tK/Ii/RD2EtVUlpRG4q6QTFbssLMImUfcdoggHsfCqjq3apUs8bR81oN9UVoYiP8tn5sWIUyRBxIEzXpqa4rx04KY8xNYqeZ jakub@status.im",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrYtuXQi7TkyGVsXtd81LyOLihMHpZFZnArrNn8m90lOmohSwD8pSgX+Lhw+yEguSgnBhYIDWxDzZqGHIMXquCwwK6Kv4RT+IpwX9m5yMUJbReLAe5NbjX3thGkd9+wHFqpHnO7bzLuKeNqyYdm6I8/l3e4P6fG7NOvDReSX4lNoSZpOJD9pmzxH1rv4kI/NfKxhm88rpZ2D6Nx2k9Eep3KjVYTIUFTre98eoV/4USrAB0Mj8nHqA/i0nTni2pf8rBYp0xlLik91+k2skLrHgfUi4LuzEkudGYZPdDSC1qrsB6qjmO0z6lEyYIUpr9My7vANKT9MT5VKsNJomATChlD1x3THjW++2aQ+XXHYkmTqKixPzJiB1D8SWBKnEI1wjKadv2J8RuTBPeybtBfuY3Mqj9U2xrp7Rr3l/ciiSk+z2v3HGW4XFtaMpmOc69sghE9nu+0lEEkA7o+Xlml2PUdPfFPmO3G1PRcK9v/Fyz6BPMZhaDCiENS6IhapsuNAUiEp8FriocAInd/UKlJyH+ydZ9d/ivQ3XaMuOr6AOpbwO+MZEPEGJG051+SFyXUWaN6xWQx2cAgSgF4yjbZpeIfkOoOdIu9BDmCR3rD0L4W4RxBTop8OJ+eZaGNvdk8T0Ty5/tlxmL1tKjktlPjMFv2Nr/laTmUyLuKefQlW1Y4w== arthur@status.im"
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

