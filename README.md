# Description

This is a helper module used by Status internal repos like: [infra-hq](https://github.com/status-im/infra-hq), [infra-misc](https://github.com/status-im/infra-misc), [infra-eth-cluster](https://github.com/status-im/infra-eth-cluster), or [infra-swarm](https://github.com/status-im/infra-swarm).

# Usage

Simply import the modue using the `source` directive:
```hcl
module "google-cloud" {
  source = "github.com/status-im/infra-tf-google-cloud"
}
```

[More details.](https://www.terraform.io/docs/modules/sources.html#github)

# Variables

* __Scaling__
  * `host_count` - Number of hosts to start in this zone.
  * `image` - OS image used to create host. (default: `ubuntu-os-cloud/ubuntu-1804-lts`)
  * `type` - Type of machine to deploy. (default: `n1-standard-1`)
  * `zone` - Specific zone in which to deploy hosts. (default: `us-central1-a`)
  * `root_vol_size` - Size of the base/root image. (default: `10`)
  * `data_vol_type` - Type of the extra data volume. (default: `pd-balanced`)
  * `data_vol_size` - Size of the extra data volume. (default: `0`)
* __General__
  * `name` - Prefix of hostname before index. (default: `node`)
  * `group` - Name of Ansible group to add hosts to.
  * `env` - Environment for these hosts, affects DNS entries.
  * `domain` - DNS Domain to update.
* __Security__
  * `ssh_user` - User used to log in to instance (default: `root`)
  * `ssh_keys` - Names of ssh public keys to add to created hosts.
  * `open_tcp_ports` - TCP port ranges to enable access from outside. Format: `N-N` (default: `[]`)
  * `open_udp_ports` - UDP port ranges to enable access from outside. Format: `N-N` (default: `[]`)
  * `blocked_ips` - IP Address ranges to block. Format: [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) (default: `[]`)
