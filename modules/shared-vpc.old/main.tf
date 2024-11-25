# Set Some Locals
locals {
  url_prefix       = "https://www.googleapis.com/compute/v1/"
  host_project_id  = lower(trimspace(var.host_project_id))
  credentials_file = var.credentials_file != null ? lower(trimspace(var.credentials_file)) : null
  org_id           = var.org_id != null ? lower(trimspace(var.host_project_id)) : null
  folder_id        = var.folder_id != null ? lower(trimspace(var.folder_id)) : null
  query_org        = local.org_id != null ? true : false
  query_folder     = local.folder_id != null ? true : false
  filter           = "${local.query_folder ? "parent.id:${var.folder_id} " : ""}lifecycleState:ACTIVE"
  network          = var.network != null ? lower(trimspace(var.network)) : null
}

# Get all Available Regions
data "google_compute_regions" "available" {
  project = local.host_project_id
}

# Get all Networks for Shared VPC Host Project
data "google_compute_networks" "shared_vpc" {
  project = local.host_project_id
}

# Filter networks to specific scope; build active regions list from their subnet lists
locals {
  all_networks = data.google_compute_networks.shared_vpc.networks
  all_regions  = data.google_compute_regions.available.names
  regions      = [for region in coalescelist(var.regions, local.all_regions) : trimspace(lower(region))]
  available_networks = var.name_prefix != null ? flatten([
    for network in local.all_networks :
    [
      for region in local.regions :
      network if network == "${var.name_prefix}-${region}"
    ]
  ]) : coalescelist([local.network], local.all_networks)
}

# Get more detailed information for each network, namely subnetworks list
data "google_compute_network" "shared_vpc" {
  for_each = toset(local.available_networks)
  project  = local.host_project_id
  name     = each.value
}

# Use subnets to determine which regions we're actually using
locals {
  active_regions = toset(flatten([for network in local.available_networks :
    [for subnetwork_self_link in data.google_compute_network.shared_vpc[network].subnetworks_self_links :
      element(reverse(split("/", subnetwork_self_link)), 2) if network != "default" # returns region name
    ]
  ]))
}

# Get all Active Projects
data "google_projects" "active_projects" {
  filter = local.filter
}

# Organize projects list by Project ID
locals {
  all_projects = var.projects != null ? [
    for project in data.google_projects.active_projects.projects : project if contains(var.projects, project.project_id)
  ] : data.google_projects.active_projects.projects
  active_projects = {
    for project in local.all_projects :
    project.project_id => {
      number = lookup(project, "number", 0)
      regions = flatten([
        for region in local.active_regions :
        [for label in var.regional_labels : region if lookup(project.labels, label, "") == region]
      ])
    } if lookup(project, "labels", null) != null
  }
}

# Get all Private Subnets for Host Network Project
data "google_compute_subnetworks" "private_subnets" {
  for_each = toset(local.regions)
  project  = local.host_project_id
  region   = each.value
  filter   = "purpose eq PRIVATE"
}

# Organize Subnets by Region
locals {
  private_subnets = { for k, v in data.google_compute_subnetworks.private_subnets : k => v.subnetworks }
  subnets = { for region, subnets in local.private_subnets :
    region => [for subnet in subnets :
      {
        id      = replace(subnet.self_link, local.url_prefix, "")
        name    = subnet.name
        region  = region
        network = subnet.network_self_link # This is network name, not network self link
      } if contains(local.available_networks, subnet.network_self_link)
    ]
  }
  shared_subnets = flatten([for region, subnets in local.subnets :
    [for subnet in subnets :
      merge(subnet, {
        attached_projects = flatten([for project_id, project in local.active_projects :
          [for region in project.regions : project_id if subnet.region == region]
        ])
      })
    ]
  ])
  attached_projects = keys(local.active_projects)
  scope_prefix      = local.query_org ? "organisations" : local.query_folder ? "folders" : "projects"
  services_scopes = coalescelist(
    local.query_org ? [local.org_id] : [],
    local.query_folder ? [local.folder_id] : [],
    [for project_id in local.attached_projects : project_id]
  )
}

# Given the Project ID, retrieve enabled services (APIs)
data "google_cloud_asset_resources_search_all" "services" {
  for_each    = toset(local.services_scopes)
  scope       = "${local.scope_prefix}/${each.key}"
  asset_types = ["serviceusage.googleapis.com/Service"]
  provider    = google-beta
}

locals {
  cloud_assets = data.google_cloud_asset_resources_search_all.services
  projects = { for project_id in local.attached_projects :
    project_id => {
      number  = local.active_projects[project_id].number
      regions = local.active_projects[project_id].regions
      apis = toset(flatten([for scope in local.services_scopes :
        [for result in local.cloud_assets[scope].results : result.display_name]
      ]))
    }
  }
  service_accounts = { for project_id, project in local.projects :
    project_id => compact([
      contains(project.apis, "compute.googleapis.com") ? "serviceAccount:${project.number}@cloudservices.gserviceaccount.com" : null,
      contains(project.apis, "compute.googleapis.com") ? "serviceAccount:${project.number}-compute@developer.gserviceaccount.com" : null,
      contains(project.apis, "container.googleapis.com") ? "serviceAccount:service-${project.number}@container-engine-robot.iam.gserviceaccount.com" : null,
    ])
  }
  subnet_iam_bindings = { for subnet in local.shared_subnets :
    subnet.id => {
      region = subnet.region
      members = flatten([for project_id in subnet.attached_projects :
        local.service_accounts[project_id] if contains(local.projects[project_id].regions, subnet.region)
      ])
      role = "roles/compute.networkUser"
    } if length(subnet.attached_projects) > 0
  }
}

# Give Compute Network User permissions to each subnet
resource "google_compute_subnetwork_iam_binding" "default" {
  for_each   = { for k, v in local.subnet_iam_bindings : k => v }
  project    = local.host_project_id
  subnetwork = each.key
  region     = each.value.region
  members    = each.value.members
  role       = each.value.role
}
