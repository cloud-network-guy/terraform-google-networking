variable "create" {
  description = "Create resources?"
  type        = bool
  default     = true
}
variable "project" {
  description = "GCP Project ID"
  type        = string
}
variable "environment" {
  description = "Environment"
  type        = string
}
variable "network_project" {
  description = "Project ID of the shared DMZ network"
  type        = string
  default     = null
}
variable "cloud_router_bgp_asn" {
  description = "BGP ASN to use for Cloud Routers on our side"
  type        = string
  default     = 64512
}
variable "peer_bgp_asn" {
  description = "BGP ASN to use for remote side"
  type        = string
  default     = 65000
}
variable "regions" {
  description = "List of Regions to deploy Connectivity"
  type = map(object({
    cloud_router_bgp_asn = optional(number)
    psc_consumers_cidr   = optional(string)
    proxy_only_cidr      = optional(string)
    dns_domain           = optional(string)
    dns_hostname         = optional(string)
    dns_aliases          = optional(list(string), [])
    psc_consumers = optional(list(object({
      target_service = string
      nat_subnet     = string
      name           = optional(string)
      description    = optional(string)
      create         = optional(bool, true)
    })), [])
    vpns = optional(list(object({
      create                             = optional(bool, true)
      name                               = string
      description                        = optional(string)
      peer_bgp_asn                       = optional(number)
      peer_vpn_gateway                   = string
      advertised_route_priority          = optional(number)
      custom_learned_route_priority      = optional(number)
      tunnel_advertised_route_priorities = optional(list(number))
      tunnel_ike_psk                     = optional(list(string))
      tunnel_ip_ranges                   = optional(list(string))
    })), [])
    interconnects = optional(list(object({
      create                        = optional(bool, true)
      description                   = optional(string)
      mtu                           = optional(number)
      peer_bgp_asn                  = optional(number)
      advertised_route_priority     = optional(number)
      custom_learned_route_priority = optional(number)
      advertised_route_priorities   = optional(list(number))
      attachment_names              = optional(list(string))
      peer_names                    = optional(list(string))
      interface_names               = optional(list(string))
      ip_ranges                     = optional(list(string))
      peer_ip_addresses             = optional(list(string))
    })), [])
    advertised_ip_ranges = optional(
      list(object({
        range       = string
        description = optional(string)
    })), [])
  }))
  default = {}
}
variable "peer_vpn_gateways" {
  description = "External / Peer VPN Gateways used by Customer"
  type = map(object({
    description = optional(string)
    bgp_asn     = optional(number, 65000)
    create      = optional(bool, true)
    interfaces = list(object({
      ip_address  = string
      description = optional(string)
      bgp_asn     = optional(number)
    }))
  }))
  default = {}
}
variable "dns_zones" {
  description = "List of DNS zones"
  type = map(object({
    create          = optional(bool, true)
    project_id      = optional(string)
    host_project_id = optional(string)
    host_project    = optional(string)
    key             = optional(string)
    dns_name        = string
    name            = optional(string)
    description     = optional(string)
    visibility      = optional(string)
    networks        = optional(list(string))
    peer_project    = optional(string)
    peer_network    = optional(string)
    logging         = optional(bool)
    force_destroy   = optional(bool)
    target_name_servers = optional(list(object({
      ipv4_address    = string
      forwarding_path = optional(string, "default")
    })))
    records = optional(list(object({
      create  = optional(bool, true)
      key     = optional(string)
      name    = string
      type    = optional(string)
      ttl     = optional(number)
      rrdatas = list(string)
    })))
  }))
  default = {}
}
variable "create_peering_to_network_project" {
  description = "Whether to create a VPC network peering connection to DMZ network in core network project"
  type        = bool
  default     = true
}
variable "create_cloud_vpn_gateways" {
  description = "Whether to create VPN gateways on GCP end"
  type        = bool
  default     = null
}
variable "vpn_ike_psk_length" {
  description = "Length of IKE pre-shared keys"
  type        = number
  default     = 20
}
variable "psc_consumer_subnetwork_name" {
  type    = string
  default = "psc-consumers"
}
variable "set_null_subnetwork_for_psc_consumers" {
  description = "Leave subnetwork field empty when creating PSC consumer forwarding rules"
  type        = bool
  default     = false
}
variable "proxy_only_subnetwork_name" {
  type    = string
  default = "proxy-only-subnet"
}
variable "internal_ip_addresses" {
  description = "List of trusted IP ranges"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "100.64.0.0/10", "198.18.0.0/15"]
}
variable "interconnect_mtu" {
  description = "Default MTU Value for Interconnects"
  type        = number
  default     = 1440
}
