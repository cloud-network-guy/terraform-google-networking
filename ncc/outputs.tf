output "ncc_hub" {
  value = module.ncc.ncc_hub
}
output "hybrid_spokes" {
  value = module.ncc.hybrid_spokes
}
output "spokes" {
  value = flatten([for spoke in module.ncc.spokes :
    [
      for spoke_key, v in spoke :
      {
        name        = v.name
        description = v.description
        #status                = v.status
        project = v.project
        hub     = v.hub
        group   = v.group
        id      = v.id
        #include_export_ranges = v.include_export_ranges
        #exclude_export_ranges = v.exclude_export_ranges
      }
    ]
  ])
}
output "groups" {
  value = module.ncc.groups
}
