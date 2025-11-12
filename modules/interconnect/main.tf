

# Create a local to hand off to child module
locals {
  interconnect = {
    name_prefix          = var.name_prefix
    region               = var.region
    type                 = var.type
    mtu                  = var.mtu
    encryption           = var.encryption
    cloud_router         = var.cloud_router
    advertised_priority  = var.advertised_priority
    advertised_ip_ranges = [for advertised_ip_range in var.advertised_ip_ranges : { range = advertised_ip_range }]
    attachments = [for i, attachment in var.attachments :
      merge(attachment, {
        peer_bgp_asn             = coalesce(attachment.peer_bgp_asn, var.peer_bgp_asn)
        advertised_ip_ranges     = [for advertised_ip_range in var.advertised_ip_ranges : { range = advertised_ip_range }]
        ipsec_internal_addresses = attachment.ipsec_internal_addresses
      })
    ]
  }
}

# Call Hybrid Networking Child Module
module "interconnect" {
  source        = "../hybrid-networking"
  project_id    = var.project_id
  region        = var.region
  interconnects = [local.interconnect]
}
