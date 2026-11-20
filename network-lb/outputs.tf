
output "health_checks" {
  value = { for k, v in local.health_checks :
    k => { for _ in ["name", "id", "self_link"] : _ => lookup(module.healthchecks[k], _, null) }
  }
}
output "backends" {
  value = { for k, v in local.backends :
    k => { for _ in ["name", "id", "self_link"] : _ => lookup(module.backends[k], _, null) }
  }
}
output "frontends" {
  value = { for k, v in local.frontends :
    k => { for _ in ["name", "id", "self_link"] : _ => lookup(module.frontends[k], _, null) }
  }
}