# Description

This is a helper module used by Status internal repos like:

* https://github.com/status-im/infra-hq
* https://github.com/status-im/infra-misc
* https://github.com/status-im/infra-eth-cluster
* https://github.com/status-im/infra-swarm

# Usage

Simply import the modue using the `source` directive:
```terraform
module "google-cloud" {
  source = "github.com/status-im/infra-tf-google-cloud"
}
```

For more details see:
https://www.terraform.io/docs/modules/sources.html#github

# Variables

* __Scaling__
  * `count` - Number of hosts to start in this zone.
  * `image` - OS image used to create host. (default: `ubuntu-18-04-x64`)
  * `type` - Type of machine to deploy. (default: `s-1vcpu-1gb`)
  * `zone` - Specific zone in which to deploy hosts. (default: `ams3`)
  * `vol_size` - Size of the base image. (default: `10`)
* __General__
  * `name` - Prefix of hostname before index. (default: `node`)
  * `group` - Name of Ansible group to add hosts to.
  * `env` - Environment for these hosts, affects DNS entries.
  * `domain` - DNS Domain to update.
* __Security__
  * `ssh_user` - User used to log in to instance (default: `root`)
  * `ssh_keys` - Names of ssh public keys to add to created hosts.
  * `open_ports` - Port ranges to enable access from outside. Format: `N-N` (default: `[]`)
