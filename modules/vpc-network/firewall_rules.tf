
locals {
  _firewall_rules = [for rule in coalesce(var.firewall_rules, []) :
    merge(rule, {
      create      = local.create ? coalesce(rule.create, true) : false
      name        = rule.name != null ? lower(trimspace(rule.name)) : null
      description = rule.description != null ? trimspace(rule.description) : null
      disabled    = coalesce(rule.disabled, false)
      priority    = coalesce(rule.priority, 1000)
      logging     = coalesce(rule.logging, false)
      direction   = length(coalesce(rule.destination_ranges, [])) > 0 ? "EGRESS" : upper(coalesce(rule.direction, "ingress"))
      action      = upper(coalesce(rule.action, rule.allow != null ? "ALLOW" : (rule.deny != null ? "DENY" : "ALLOW")))
      ports       = toset(coalesce(rule.ports, compact([rule.port])))
      protocols   = toset(coalesce(rule.protocols, coalescelist(compact([rule.protocol]), ["all"])))
      range_types = toset([for range_type in compact(coalesce(rule.range_types, [rule.range_type])) :
        lower(trimspace(range_type))
      ])
    })
  ]
}

# Get Current IP Ranges from Google via Data Source
data "google_netblock_ip_ranges" "default" {
  for_each   = toset(flatten([for rule in local._firewall_rules : rule.range_types if rule.create]))
  range_type = each.value
}

locals {
  __firewall_rules = [for i, rule in local._firewall_rules :
    merge(rule, {
      name                    = coalesce(rule.name, "fwr-${local.network_name}-${i}")
      source_tags             = rule.direction == "INGRESS" ? rule.source_tags : null
      source_service_accounts = rule.direction == "INGRESS" ? rule.source_service_accounts : null
      source_ranges = rule.direction == "INGRESS" ? toset(coalesce(
        rule.source_ranges,
        rule.ranges,
        compact(flatten([for rt in rule.range_types :
          try(data.google_netblock_ip_ranges.default[lower(rt)].cidr_blocks, null)
        ])),
        [],
      )) : null
      destination_ranges = rule.direction == "EGRESS" ? toset(coalesce(
        rule.destination_ranges,
        rule.ranges,
        compact(flatten([for rt in rule.range_types :
          try(data.google_netblock_ip_ranges.default[lower(rt)].cidr_blocks, null)
        ])),
        [],
      )) : null
      traffic = coalesce(
        rule.action == "ALLOW" && rule.allow != null ? [for allow in rule.allow :
          {
            protocol = lower(trimspace(allow.protocol))
            ports    = toset(allow.ports)
          }
        ] : null,
        rule.action == "DENY" && rule.deny != null ? [for deny in rule.deny :
          {
            protocol = lower(trimspace(deny.protocol))
            ports    = toset(deny.ports)
          }
        ] : null,
        [for protocol in rule.protocols :
          {
            protocol = lower(trimspace(protocol))
            ports    = toset(rule.ports)
          }
        ],
      )
    })
  ]
  firewall_rules = [for rule in local.__firewall_rules :
    merge(rule, {
      # If no IP ranges, use 169.254.169.254 since allowing 0.0.0.0/0 may not be intended
      source_ranges      = rule.direction == "INGRESS" && rule.source_tags == null && rule.source_service_accounts == null ? coalescelist(tolist(rule.source_ranges), ["169.254.169.254"]) : null
      destination_ranges = rule.direction == "EGRESS" ? coalescelist(tolist(rule.destination_ranges), ["169.254.169.254"]) : null
      index_key          = coalesce(rule.index_key, rule.name)
    }) if local.recreate == false
  ]
}

# VPC Firewall Rules
resource "google_compute_firewall" "default" {
  for_each                = { for i, v in local.firewall_rules : v.index_key => v if v.create }
  project                 = local.project
  network                 = local.network_self_link
  name                    = each.value.name
  description             = each.value.description
  priority                = each.value.priority
  direction               = each.value.direction
  disabled                = each.value.disabled
  source_ranges           = each.value.source_ranges
  source_tags             = each.value.source_tags
  source_service_accounts = each.value.source_service_accounts
  destination_ranges      = each.value.destination_ranges
  dynamic "allow" {
    for_each = each.value.action == "ALLOW" ? each.value.traffic : []
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }
  dynamic "deny" {
    for_each = each.value.action == "DENY" ? each.value.traffic : []
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
  dynamic "log_config" {
    for_each = each.value.logging ? [true] : []
    content {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
  target_tags             = each.value.target_tags
  target_service_accounts = each.value.target_service_accounts
  timeouts {
    create = null
    delete = null
    update = null
  }
}

