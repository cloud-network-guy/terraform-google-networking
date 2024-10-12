output "interconnect" {
  value = {
    region       = local.interconnect.region
    cloud_router = local.interconnect.cloud_router
    attachments  = module.interconnect.interconnect_attachments
  }
}
