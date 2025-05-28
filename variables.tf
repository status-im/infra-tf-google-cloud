/* DNS ------------------------------------------*/

variable "cf_zone_id" {
  description = "ID of CloudFlare zone for host record."
  type        = string
  default     = "fd48f427e99bbe1b52105351260690d1"
}

variable "domain" {
  description = "DNS Domain to update"
  type        = string
  default     = "status.im"
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
    # jakub@status.im
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeWB4SeXQfEsfkNPOkSLoTQ/7VDpf8CsaRQ+waCHEEv4v2fFc/9lMbQ6Z208UEQKJMOMdtwd3eB7j6aFIirMQTYcm/NuxPLdRRnlxLNJIVMBfKUV5V3OkbneqzBTEvtAaIDC506kIlXxAPfZCDVxzAi7B+NkHUvhjCEjScM2KfamahDZUbj2ww2Q/82P1Qj8QY/1b2wC6OXBnKPUQIzAzrxDNYWaXdB/4DysDcib50kd2URenpMVU1DCjSWXBniSnpEVh0Lxjehsnfg+oE3BP3u6wA+1xufukH9h9eQ/hTM1PXEVC2ObpgESRYxc3rqkqVxYbOzrmCRVJpvKoGs+W89vIoFUt6/tzunAMogo2VHhT7LnGE4iizj9YODxIdpRMGGeMgZiceoOuNFAjKg8Qay4aoE50uklim4ircOXgrAasRotUcz28EU5oaV9/NO+GKNzooRNBX2U/c1MsTI+6mz7ppMq0NCHOpO5sY1qC8F2lZbDDGQgC25btqu+xnbqHwCDSst2Sy5yvF3C34F/Xt8kw3zkraB1OmTWwW/QIA+o3AViaA59r+ZicIIEWvUbUbcMD/GFDesOgzK8V9G6kZNuQoEVsq9FHEMTpsGSBDOIHn4aWP+7gQK2FhvyXBGj/z/NDFY1H+I2KvhI0rkV3NaTtUy0+51uKO5Efnx8cQyw== jakub@status.im",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5NIT2SVFFjV+ZraPBES45z8wkJf769P7AXdZ4FiJw+DcXKawNJCUefeBQY5GVofVOzOHUrkYLqzxVJihIZJaDgeyME/4pLXYztkk9EOWdQSadxLJjWItMJULJrh5nnXzKxv5yy1SGJCTcMSXrvR6JRduu+KTHGncXJ2Ze6Bdgm63sOdfyPCITSC+nc4GexYLAQmBxXCwtKieqfWVmKpazlVDxAg3Q1h2UXOuLTjkWomvzVCggwhzHtN/STQMCH49PlW/VoIBlrpYqlmRGObsdBae4Bk/D5ZpisJi6w573RcF9q3VrqJTHLiSpntfVJEtsbmyiNNckIujQfRk2KYvSCK2iGP17hfCE9HmEfSZNWrKrMqKJ7gHOhXHJrszh6TtN9zmgomPvYolJBLz/2/JC8swfixHPMzxQa+P2NyqC0yWg8Xqd1JLWKLHsLwpEYvmOfyYIY8zOfk7y3OJX8h7D/fgbnG/V75EVuZDc8sqXTJpj3esoEsz8XVu9cVraAOodG4zYKFnoTomAzBJtImh6ghSEDGT5BAvDyFySyJGMibCsG5DwaLvZUcijEkKke7Z7OoJR4qp0JABhbFn0efd/XGo2ZyGtJsibSW7ugayibEK7bDaYAW3lNXgpcDqpBiDcJVQG/UhhCSSrTsG0IUSbvSsrDuF6gCJWVKt4+klvLw== jakub@status.im",
    # alexis@status.im
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHb8ORNUIJkwUACMl59CvbqJJ2dFVL2QYDtJhAgehKRQSW87nU2GtAc/23ncC7BsDJMolAare3gDODpcfxlDcrHOG6O9FQmakEY0AMRO0Wk4uJHRCCPjxyYLoRUNKOUjmpY6JEG+ZzKjRGqMcvH19PmzUOkR2thdJBJ8tluXEk/UraFoSJUcA8dRxou2o9jdLtTPJIRyZNkhiRXrnD+8rD6a+VqM2JWqTqg/Mgj6EaZHyXcg2xAtXHEbVl5MIAbWPwCz2DjVNp52dEe3GyUFdlFr8Rp7TVPfA8qe+hbrs2V+ubdgEAFxQBfsSoY9UPjhdO8Yl3nhqNvXOKRTQ+EJLdlGobJUG2blrAyleyREomSixOIf6LM6HwdRxPz1QzGf8kKvqyIWtzR/s7xoV3ELLTzxyrUZF9yLrRYbdlqnxIKErb6lrwB3WUIAaT7ZQdJpRZvM5kNPg3Z2ZQZzs7SdQ/d3N4CYptr+mXHOze2cazE6DYyCshk9E4C70pBMejfaRM8RCjky6jDkODNKvu9sJXtKHyX7QceSnK83jPE/1taDLhOfFxezcqSNATtATENd8D6ulTTxflWU+cxfsCEoAUIaat5ORINYFsLlxdf3VUAKZNNmWiEB7cWKzdXbiRuqSpTAyuIxdFpFCe3GrM2R+LunsEmx/qWsDyhYjU0t7C7w== alexis@status.im",
    # anton@status.im
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWR0sBIp/KRFxbJgYKFSSuk2vKANZwxmina7Y96KN7U3kqz5Gulkm6VhbR1sNYigTYSmnSZz96BKxdBAFy4k63zMzu2IK68QmgD7fevIOuNXaGdlGhA1zYYUF1uKyLUHnzvdmaP6M3x+xXIZT1ftfvPRHCJcrjIyp8JLbYvB+Qo6Gxr/FY7imXH0jJmOh60yfv0XGy0L+8jriR4Lr8xfzkany1qQH4GgatjhLaVWSfbTbNypbsnFeB3GXFQqSpY6ESk/FoSYB1LFyTWx+sAW8fyHdAcBljBczELqbJ8JDiO8FFT0iLFOVEm0Z8QzZOC6Ii3HWAs9+pGhGktoL6qLpIziYA8e3uPYNdXQRqwqnkDnRsduwKgmrX05QPgE0DQaoWpS4nqsBfD5a7FmBE79+8SztUlJ/tNVatDjy25fA2etTPmq+3fxjty9CDqRG49xFswaUSyGpabTb6pTcnSVCnJSj3PhCsRvEBn2OyR+alCTKvMYeueH/eQigjzh16Lu0ylDzeGidmA3AoOQHI+zQsATzCPUq2DkCdQUp+wvoezKOsodlnJ7lomAalkmFFLdYrYewRah3JzirAiFAtBZDpB+IdpPFigAhWq2DdEh7/a14M2dHKqkmjdJvRVRgQ3UfG6PG21lWljRMCxNaAqqsLFKLsR+IQBu3I2ceSraxXoQ== yakimant@gmail.com",
    "no-touch-required sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJXqUxcqsY1U4xG1WlRS0WCaFHeF1MXp3wWhCPuW+b2rAAAADHNzaDpuby10b3VjaA== yakimant@gmail.com",
    # marko@status.im
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2kD/iiRO/tXHo17Rj8r+BytNOUX7S/9VexcYPag/nyqiWn7Ti6A4rxc608C4taj4QpxX1kyPXhD1vdUeyA2eWulStnrDVI4ULhjb29MnVc6k9q5U4rXnuao5ksOjez3VIG0sITGFPGmr+jIlHQZLnpatdSrmh+uj3LSnPerOH7HeHBI4F9ATCtYDdW1xqStwogiaJXVNHX6lxhK/9TlPcpdkY4LbfUdQe48DjdAdN3rFnIAj8iTGL55e0bKQQRw+iqr3OyC/IGeQAPZXBsWSmJX4mIgadaf2Lo0dK4S5RbP2yOsG6eo07eZJq2bYbMoSuCpeYynNUgXF1bXBVSD0z1iC05v25sqyz6HsB843l4F6NEZnUp+DDpemWsZCCWfjouEKCMe91OmYpIt/hOLWumh/oyuSJG9kPCRQmHj5eCxcoxDPrAthJ2XM45WqKCRo7SGdXlEEhrA4iAf2874Io6fERd++bzUVtPyPF77Cgmhs3D/3TSwuUEA3T8Z1bbGU2YWf153B7Haqme3zkqswRKca5LuQ33F5eXxN/xyCEVsNiTt7F68XteNV7eAcZ5vZZ7k29iZk7iVIIJawF1ydS+5Irr79sVLIvhkzm524xGxysspSGCoI4AABYEPlNQkyfnMLtGKMpPRkAEdO1QplaalHPDP6MHIysVRGGiLZV4w== openpgp:0xCC75A7BC"
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

