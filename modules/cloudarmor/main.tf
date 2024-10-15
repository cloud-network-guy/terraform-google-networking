
locals {
  create      = coalesce(var.create, true)
  project_id  = lower(trimspace(var.project_id))
  name        = lower(trimspace(var.name))
  description = coalesce(var.description, "Managed by Terraform")
  rules = length(var.rules) > 0 ? [for rule in var.rules :
    {
      action      = lower(lookup(rule, "action", "allow"))
      priority    = lookup(rule, "priority", 2147483646)
      description = lookup(rule, "description", null)
      ip_ranges   = lookup(rule, "ip_ranges", null)
      expr        = lookup(rule, "expr", null)
    }
    ] : [
    {
      action      = "allow"
      priority    = 2147483646
      description = null
      ip_ranges   = ["*"]
      expr        = null
    }
  ]
  index_key = "${local.project_id}/${local.name}"
}

resource "google_compute_security_policy" "default" {
  count       = local.create == true ? 1 : 0
  project     = local.project_id
  name        = local.name
  description = local.description
  dynamic "rule" {
    for_each = local.rules
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description
      match {
        versioned_expr = rule.value.ip_ranges != null ? "SRC_IPS_V1" : null
        dynamic "config" {
          for_each = rule.value.ip_ranges != null ? [true] : []
          content {
            src_ip_ranges = rule.value.ip_ranges
          }
        }
        dynamic "expr" {
          for_each = rule.value.expr != null ? [true] : []
          content {
            expression = rule.value.expr
          }
        }
      }
    }
  }
  rule {
    action = "deny(403)"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule, higher priority overrides it"
    priority    = 2147483647
  }
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable          = var.layer_7_ddos
      rule_visibility = null
    }
  } # (1 unchanged at
}

