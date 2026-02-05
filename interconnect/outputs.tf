output "interconnect" {
  value = {
    region       = local.region
    cloud_router = local.router
    attachments = { for i, v in local.interconnect_attachments :
      "${local.project}/${local.region}/${v.name}" => {
        index_key                  = "${local.project}/${local.region}/${v.name}"
        name                       = v.name
        bandwidth                  = try(google_compute_interconnect_attachment.default[v.name].bandwidth, "Unknown")
        edge_availability_domain   = local.type == "PARTNER" ? google_compute_interconnect_attachment.default[v.name].edge_availability_domain : null
        vlan_tag8021q              = try(google_compute_interconnect_attachment.default[v.name].vlan_tag8021q, 0)
        pairing_key                = local.type == "PARTNER" ? google_compute_interconnect_attachment.default[v.name].pairing_key : null
        private_interconnect_info  = local.type == "DEDICATED" ? google_compute_interconnect_attachment.default[v.name].private_interconnect_info : null
        cloud_router_ip_address    = try(google_compute_interconnect_attachment.default[v.name].cloud_router_ip_address, "Unknown")
        customer_router_ip_address = try(google_compute_interconnect_attachment.default[v.name].customer_router_ip_address, "Unknown")
        state                      = try(google_compute_interconnect_attachment.default[v.name].state, "Unknown")
        pairing_key                = try(google_compute_interconnect_attachment.default[v.name].pairing_key, null)
      }
    }
  }
}
