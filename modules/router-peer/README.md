# Cloud Router Peer Module

Manages `google_compute_router_interface` and `google_compute_router_peer` resources
against an **existing** Cloud Router. This module intentionally does not create the
router, the VPN tunnels, or the Interconnect attachments themselves — those are
expected to come from the root module (or other modules it composes), and are
passed in as plain strings (name or self_link) via `vpn_tunnel` /
`interconnect_attachment`. Each interface must be backed by exactly one of the two.

`interfaces` and `bgp_peers` are both lists of objects, each with a required
`name` field. Internally the module keys `for_each` off that `name`, so adding
or removing one entry doesn't force replacement of unrelated resources — but
the list order itself doesn't matter and shouldn't be relied on. Peers
reference their interface via `interface_name`, which must match an interface's
`name`.

## Usage: HA VPN peers

```hcl
module "router_peers" {
  source  = "./modules/router-peer"
  project = "my-project"
  region  = "us-central1"
  router  = google_compute_router.this.name

  interfaces = [
    {
      name       = "tunnel-0"
      ip_range   = "169.254.0.1/30"
      vpn_tunnel = google_compute_vpn_tunnel.tunnel_0.name
    },
    {
      name       = "tunnel-1"
      ip_range   = "169.254.1.1/30"
      vpn_tunnel = google_compute_vpn_tunnel.tunnel_1.name
    },
  ]

  bgp_peers = [
    {
      name            = "on-prem-0"
      interface_name  = "tunnel-0"
      peer_asn        = 65001
      peer_ip_address = "169.254.0.2"
      advertise_mode  = "DEFAULT"
    },
    {
      name            = "on-prem-1"
      interface_name  = "tunnel-1"
      peer_asn        = 65001
      peer_ip_address = "169.254.1.2"
      advertise_mode  = "DEFAULT"

      bfd = {
        session_initialization_mode = "ACTIVE"
        min_transmit_interval       = 1000
        min_receive_interval        = 1000
        multiplier                  = 5
      }
    },
  ]
}
```

## Usage: custom route advertisement + MD5 auth

```hcl
bgp_peers = [
  {
    name            = "partner-peer"
    interface_name  = "tunnel-0"
    peer_asn        = 65002
    peer_ip_address = "169.254.2.2"
    advertise_mode  = "CUSTOM"

    advertised_ip_ranges = [
      { range = "10.10.0.0/16", description = "internal-prod" },
      { range = "10.20.0.0/16", description = "internal-staging" },
    ]

    md5_authentication_key = {
      name = "key1"
      key  = var.bgp_md5_secret
    }
  },
]
```

## Usage: Interconnect attachment interface

```hcl
module "router_peers" {
  source  = "./modules/router-peer"
  project = "my-project"
  region  = "us-central1"
  router  = google_compute_router.this.name

  interfaces = [
    {
      name                    = "xlan-attach-0"
      ip_range                = "169.254.10.1/29"
      interconnect_attachment = google_compute_interconnect_attachment.this.name
    },
  ]

  bgp_peers = [
    {
      name            = "xlan-peer-0"
      interface_name  = "xlan-attach-0"
      peer_asn        = 65003
      peer_ip_address = "169.254.10.2"
    },
  ]
}
```

## Mixing both in one router

Because each interface independently declares `vpn_tunnel` or
`interconnect_attachment`, a single module call can manage a mix of both against
the same router — useful for a router that terminates some peers over VPN and
others over Interconnect:

```hcl
interfaces = [
  { name = "tunnel-0", ip_range = "169.254.0.1/30", vpn_tunnel = google_compute_vpn_tunnel.t0.name },
  { name = "xlan-attach-0", ip_range = "169.254.10.1/29", interconnect_attachment = google_compute_interconnect_attachment.this.name },
]
```

## Notes

- Each interface must set exactly one of `vpn_tunnel` or `interconnect_attachment`;
  a `validation` block on `var.interfaces` will fail plan/apply if both or
  neither are set.
- `name` must be unique within `interfaces`, and unique within `bgp_peers`
  (enforced via `validation` blocks). Renaming an entry's `name` forces
  replacement of that resource, since it drives both the map key and the
  actual GCP resource name.
- Each peer must set `interface_name` to a `name` present in `interfaces`; the
  module resolves this to the interface's resource name and creates an
  implicit dependency, so ordering is handled automatically. If
  `interface_name` doesn't match any interface, Terraform will fail during
  plan with an "Invalid index" error on the lookup.
- `advertise_mode = "CUSTOM"` is required before `advertised_ip_ranges` has any
  effect on Google's side.
- The `bgp_peers` output is marked sensitive because peer objects may include
  `md5_authentication_key`.

## Inputs

| Name       | Type         | Default | Description                                   |
|------------|--------------|---------|------------------------------------------------|
| project    | string       | null    | Project ID, defaults to provider project        |
| region     | string       | null    | Region, defaults to provider region             |
| router     | string       | n/a     | Name of the existing Cloud Router (required)    |
| interfaces | list(object) | []      | List of router interfaces (see variables.tf)    |
| bgp_peers  | list(object) | []      | List of BGP peers (see variables.tf)             |

See `variables.tf` for the full object schemas.

## Outputs

| Name                   | Description                                                  |
|-------------------------|---------------------------------------------------------------|
| interfaces              | Map (keyed by interface name) of created interface resources  |
| bgp_peers               | Map (keyed by peer name) of created peer resources (sensitive)|
| bgp_peer_ip_addresses   | Map (keyed by peer name) -> `{ ip_address, peer_ip_address }` |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16, < 8.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.16, < 8.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_router_interface.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface) | resource |
| [google_compute_router_peer.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advertise_mode"></a> [advertise\_mode](#input\_advertise\_mode) | n/a | `string` | `null` | no |
| <a name="input_advertised_groups"></a> [advertised\_groups](#input\_advertised\_groups) | n/a | `list(string)` | `[]` | no |
| <a name="input_advertised_ip_ranges"></a> [advertised\_ip\_ranges](#input\_advertised\_ip\_ranges) | n/a | <pre>list(object({<br/>    range       = string<br/>    description = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_advertised_route_priority"></a> [advertised\_route\_priority](#input\_advertised\_route\_priority) | n/a | `number` | `null` | no |
| <a name="input_bfd"></a> [bfd](#input\_bfd) | n/a | <pre>object({<br/>    session_initialization_mode = optional(string, "DISABLED")<br/>    min_transmit_interval       = optional(number)<br/>    min_receive_interval        = optional(number)<br/>    multiplier                  = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_cloud_router_ip"></a> [cloud\_router\_ip](#input\_cloud\_router\_ip) | n/a | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_create_interface"></a> [create\_interface](#input\_create\_interface) | Automatically Create Router interfaces based on BGP peers | `bool` | `true` | no |
| <a name="input_custom_learned_ip_ranges"></a> [custom\_learned\_ip\_ranges](#input\_custom\_learned\_ip\_ranges) | n/a | `list(string)` | `[]` | no |
| <a name="input_custom_learned_route_priority"></a> [custom\_learned\_route\_priority](#input\_custom\_learned\_route\_priority) | n/a | `number` | `null` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | n/a | `bool` | `true` | no |
| <a name="input_enable_ipv4"></a> [enable\_ipv4](#input\_enable\_ipv4) | n/a | `bool` | `true` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | n/a | `bool` | `false` | no |
| <a name="input_interconnect_attachment"></a> [interconnect\_attachment](#input\_interconnect\_attachment) | Name of the Interconnect attachment that uses the interface | `string` | `null` | no |
| <a name="input_interface_index"></a> [interface\_index](#input\_interface\_index) | Explicit index of the Router Interface | `string` | `null` | no |
| <a name="input_interface_ip_range"></a> [interface\_ip\_range](#input\_interface\_ip\_range) | IP Range to use on GCP Cloud Router interface | `string` | n/a | yes |
| <a name="input_interface_name"></a> [interface\_name](#input\_interface\_name) | Explicit name of the Router Interface | `string` | `null` | no |
| <a name="input_md5_authentication_key"></a> [md5\_authentication\_key](#input\_md5\_authentication\_key) | n/a | <pre>object({<br/>    name = string<br/>    key  = string<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Router Peer Name | `string` | `null` | no |
| <a name="input_peer_bgp_asn"></a> [peer\_bgp\_asn](#input\_peer\_bgp\_asn) | n/a | `number` | `null` | no |
| <a name="input_peer_bgp_name"></a> [peer\_bgp\_name](#input\_peer\_bgp\_name) | n/a | `string` | `null` | no |
| <a name="input_peer_ip_address"></a> [peer\_ip\_address](#input\_peer\_ip\_address) | n/a | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP Region Name | `string` | n/a | yes |
| <a name="input_router"></a> [router](#input\_router) | Name or URL of Cloud Router | `string` | n/a | yes |
| <a name="input_router_appliance_instance"></a> [router\_appliance\_instance](#input\_router\_appliance\_instance) | n/a | `string` | `null` | no |
| <a name="input_vpn_tunnel"></a> [vpn\_tunnel](#input\_vpn\_tunnel) | Name of the VPN tunnel that uses the interface | `string` | `null` | no |
| <a name="input_zero_custom_learned_route_priority"></a> [zero\_custom\_learned\_route\_priority](#input\_zero\_custom\_learned\_route\_priority) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interface_ip_range"></a> [interface\_ip\_range](#output\_interface\_ip\_range) | n/a |
| <a name="output_peer_ip_address"></a> [peer\_ip\_address](#output\_peer\_ip\_address) | n/a |
<!-- END_TF_DOCS -->