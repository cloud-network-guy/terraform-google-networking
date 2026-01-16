moved {
  from = module.instances.google_compute_instance.default["otl-core-network-pre-comm/us-east4-b/admin-1"]
  to   = module.instance["us-east4-b"].google_compute_instance.default[0]
}