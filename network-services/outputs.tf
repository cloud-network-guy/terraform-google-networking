output "mig_ids" {
  value = { for deployment_key, deployment in local.deployments :
    deployment_key => [for ig in local.instance_groups :
      module.instance-groups[ig.index_key].id if ig.deployment_key == deployment_key
    ]
  }
}
output "zones" {
  value = { for deployment_key, deployment in local.deployments :
    deployment_key => [for ig in local.instance_groups :
      module.instance-groups[ig.index_key].zones if ig.deployment_key == deployment_key
    ]
  }
}
output "umig_ids" {
  value = { for deployment_key, deployment in local.deployments :
    deployment_key => [for ig in local.instance_groups :
      module.instance-groups[ig.index_key].id if ig.deployment_key == deployment_key
    ]
  }
}
output "ilbs_addresses" {
  value = { for k, v in local.lb_frontends :
    k => [{
      address = module.lb-frontend[k].address
      name    = module.lb-frontend[k].address_name
    }]
  }
}
output "connected_endpoints" {
  value = { for k, v in local.lb_frontends :
    k => module.lb-frontend[k].psc_connected_endpoints
  }
}
