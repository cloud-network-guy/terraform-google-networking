locals {
  address_groups = [for k, v in var.address_groups : {
    create      = coalesce(v.create, true)
    project     = coalesce(v.project_id, local.project)
    name        = lower(trimspace(coalesce(v.name, k)))
    description = var.description != null ? trimspace(var.description) : null
    location    = lower(trimspace(v.region != null ? v.region : "global"))
    type        = "IPV4"
    capacity    = 100
    labels      = coalesce(v.labels, {})
    items       = v.items
    location    = local.region
    parent      = "projects/${local.project}"
  }]
}
resource "google_network_security_address_group" "default" {
  for_each    = { for i, v in local.address_groups : "${v.location}/${v.name}" => v if v.create }
  name        = each.value.name
  description = each.value.description
  parent      = each.value.parent
  location    = each.value.location
  type        = each.value.type
  capacity    = each.value.capacity
  items       = each.value.items
  labels      = each.value.labels
}

resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}

locals {
  api_prefix   = "https://www.googleapis.com/compute/v1"
  create       = coalesce(var.create, true)
  project      = lower(trimspace(var.project_id))
  org          = var.org_id
  name         = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  description  = var.description
  is_regional  = var.region != null ? true : false
  is_global    = !local.is_regional
  region       = local.is_regional ? lower(trimspace(var.region)) : "global"
  host_project = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  networks = [
    for network in coalesce(var.networks, []) : lower(trimspace(coalesce(
      startswith(network, local.api_prefix) ? network : null,
      startswith(network, "projects/") ? "${local.api_prefix}/${network}" : null,
      "${local.api_prefix}/projects/${local.host_project}/global/networks/${network}",
    )))
  ]
  type       = lower(trimspace(coalesce(var.type, length(local.networks) > 0 ? "network" : "unknown")))
  is_network = local.type == "network" ? true : false
}

# Global Network Firewall Policies
resource "google_compute_network_firewall_policy" "default" {
  count       = local.create && local.is_network && local.is_global ? 1 : 0
  project     = local.project
  name        = local.name
  description = local.description
}

# Regional Network Firewall Policies
resource "google_compute_region_network_firewall_policy" "default" {
  count       = local.create && local.is_network && local.is_regional ? 1 : 0
  project     = local.project
  name        = local.name
  description = local.description
  region      = local.region
}

# Locals for Rules
locals {
  _rules = [
    for rule in coalesce(var.rules, []) : merge(rule, {
      create                    = coalesce(rule.create, local.create)
      action                    = lower(coalesce(rule.action, "allow"))
      disabled                  = coalesce(rule.disabled, false)
      priority                  = coalesce(rule.priority, 1000)
      enable_logging            = coalesce(rule.logging, false)
      direction                 = upper(coalesce(rule.direction, rule.destination_ranges != null || rule.destination_address_groups != null ? "egress" : "ingress"))
      target_service_accounts   = coalesce(rule.target_service_accounts, [])
      src_ip_ranges             = rule.source_ranges
      src_address_groups        = coalesce(rule.source_address_groups, rule.address_groups, [])
      src_fqdns                 = [] # TODO
      src_region_codes          = [] # TODO
      src_threat_intelligences  = [] # TODO
      dest_ip_ranges            = rule.destination_ranges
      dest_address_groups       = coalesce(rule.destination_address_groups, rule.address_groups, [])
      dest_fqdns                = [] # TODO
      dest_region_codes         = [] # TODO
      dest_threat_intelligences = [] # TODO
      range_types               = toset(coalesce(rule.range_types, rule.range_type != null ? [rule.range_type] : []))
      protocols                 = coalesce(rule.protocols, rule.protocol != null ? [rule.protocol] : ["all"])
      ports                     = coalesce(rule.ports, compact([rule.port]))
      location                  = local.region
    })
  ]
}

# Get a list of unique range types in all rules
locals {
  firewall_policy = local.create && local.is_network ? coalesce(
    local.is_global ? one(google_compute_network_firewall_policy.default).self_link : null,
    local.is_regional ? one(google_compute_region_network_firewall_policy.default).self_link : null,
  ) : null
  range_types = toset(flatten([
    for rule in local._rules : [for rt in rule.range_types : lower(trimspace(rt))]
  ]))
}
# Use data source to lookup current IP address blocks
data "google_netblock_ip_ranges" "default" {
  for_each   = local.range_types
  range_type = each.value
}

locals {
  rules = !local.create ? [] : flatten([for i, rule in local._rules : merge(rule, {
    priority        = coalesce(rule.priority, i)
    firewall_policy = local.firewall_policy
    range_types = [
      for range_type in rule.range_types : lower(range_type)
    ]
    layer4_configs = [
      for protocol in rule.protocols : {
        ip_protocol = lower(protocol)
        ports       = contains(["tcp", "udp"], lower(protocol)) ? toset(coalescelist(rule.ports, ["1-65535"])) : []
      }
    ]
    src_ip_ranges = rule.direction == "INGRESS" ? toset(coalesce(
      rule.src_ip_ranges,
      rule.ranges,
      compact(flatten([for rt in rule.range_types :
        try(data.google_netblock_ip_ranges.default[lower(rt)].cidr_blocks, null)
      ])),
      [],
    )) : null
    dest_ip_ranges = rule.direction == "EGRESS" ? toset(coalesce(
      rule.dest_ip_ranges,
      rule.ranges,
      compact(flatten([for rt in rule.range_types :
        try(data.google_netblock_ip_ranges.default[lower(rt)].cidr_blocks, null)
      ])),
      [],
    )) : null
    src_address_groups = rule.direction == "INGRESS" ? toset(compact(flatten(
      [for address_group in rule.src_address_groups :
        try(google_network_security_address_group.default["${rule.location}/${address_group}"].id, null)
      ]
    ))) : null
    dest_address_groups = rule.direction == "EGRESS" ? toset(compact(flatten(
      [for address_group in rule.dest_address_groups :
        try(google_network_security_address_group.default["${rule.location}/${address_group}"].id, null)
      ]
    ))) : null
  }) if rule.create])
}

locals {
  network_firewall_policy_rules = [for rule in local.rules :
    merge(rule, {
      rule_name = null
      #index_key = local.is_global ? "${local.proect}/${v.name}" : "${local.project}/${local.region}/${v.name}"
    }) if local.is_network
  ]
}

# Global Network Firewall Policy Rules
resource "google_compute_network_firewall_policy_rule" "default" {
  for_each                = { for i, v in local.network_firewall_policy_rules : v.priority => v if local.is_global }
  project                 = local.project
  firewall_policy         = each.value.firewall_policy
  rule_name               = each.value.rule_name
  action                  = each.value.action
  priority                = each.value.priority
  description             = each.value.description
  direction               = each.value.direction
  disabled                = each.value.disabled
  enable_logging          = each.value.enable_logging
  target_service_accounts = each.value.target_service_accounts
  match {
    src_ip_ranges            = each.value.src_ip_ranges
    src_address_groups       = each.value.src_address_groups
    src_fqdns                = each.value.src_fqdns
    src_region_codes         = each.value.src_region_codes
    src_threat_intelligences = each.value.src_threat_intelligences
    dest_ip_ranges           = each.value.dest_ip_ranges
    dest_address_groups      = each.value.dest_address_groups
    dest_fqdns               = each.value.dest_fqdns
    dest_region_codes        = each.value.dest_region_codes
    dynamic "layer4_configs" {
      for_each = each.value.layer4_configs
      content {
        ip_protocol = layer4_configs.value.ip_protocol
        ports       = layer4_configs.value.ports
      }
    }
  }
  depends_on = [google_network_security_address_group.default]
}

# Regional Network Firewall Policy Rules
resource "google_compute_region_network_firewall_policy_rule" "default" {
  for_each                = { for i, v in local.network_firewall_policy_rules : v.priority => v if local.is_regional }
  project                 = local.project
  firewall_policy         = each.value.firewall_policy
  rule_name               = each.value.rule_name
  action                  = each.value.action
  priority                = each.value.priority
  description             = each.value.description
  direction               = each.value.direction
  disabled                = each.value.disabled
  enable_logging          = each.value.enable_logging
  target_service_accounts = each.value.target_service_accounts
  match {
    src_ip_ranges            = each.value.src_ip_ranges
    src_fqdns                = each.value.src_fqdns
    src_region_codes         = each.value.src_region_codes
    src_threat_intelligences = each.value.src_threat_intelligences
    dest_ip_ranges           = each.value.dest_ip_ranges
    dest_address_groups      = each.value.dest_address_groups
    dest_fqdns               = each.value.dest_fqdns
    dest_region_codes        = each.value.dest_region_codes
    layer4_configs {
      ip_protocol = "all"
    }
  }
  region     = local.region
  depends_on = [google_network_security_address_group.default]
}

# Associations
locals {
  network_firewall_policy_associations = [for network in local.networks :
    {
      name              = element(split("/networks/", network), length(split("/networks/", network)) - 1)
      attachment_target = network
    } if local.create
  ]
}

# Global Associations
resource "google_compute_network_firewall_policy_association" "default" {
  for_each          = { for i, v in local.network_firewall_policy_associations : v.name => v if local.is_global }
  project           = local.project
  name              = each.value.name
  attachment_target = each.value.attachment_target
  firewall_policy   = local.firewall_policy
}

# Regional Associations
resource "google_compute_region_network_firewall_policy_association" "default" {
  for_each          = { for i, v in local.network_firewall_policy_associations : v.name => v if local.is_regional }
  project           = local.project
  name              = each.value.name
  attachment_target = each.value.attachment_target
  firewall_policy   = local.firewall_policy
  region            = local.region
}
