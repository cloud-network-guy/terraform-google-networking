output "instances" {
  value = { for i, v in local.instances :
    coalesce(v.zone, v.region) => {
      #name        = module.instance[coalesce(v.zone, v.region)].name
      #zone        = module.instance[coalesce(v.zone, v.region)].zone
      #internal_ip = v.internal_ip
    } if v.create
  }
  #sensitive = false
}
