locals {
  project = lower(trimspace(var.host_project_id))
  subnetworks = [
    for s in coalesce(var.subnetworks, []) : {
      id = coalesce(
        s.id,
        s.name != null ? "projects/${local.project}/regions/${coalesce(s.region, var.region)}/subnetworks/${s.name}}" : null,
      )
      name              = s.name
      region            = coalesce(s.region, var.region)
      purpose           = coalesce(s.purpose, "PRIVATE")
      attached_projects = coalesce(s.attached_projects, [])
      shared_accounts   = coalesce(s.shared_accounts, [])
      viewer_accounts   = coalesce(s.viewer_accounts, [])
    }
  ]
  service_project_ids = toset(flatten([
    for s in local.subnetworks : lookup(s, "attached_projects", [])
  ]))
}

# Enable Project as a Shared VPC Service Project
resource "google_compute_shared_vpc_service_project" "default" {
  for_each        = local.service_project_ids
  host_project    = local.project
  service_project = each.value
}

# Get details for each service project
data "google_project" "service_projects" {
  for_each   = local.service_project_ids
  project_id = each.value
}

# Cloud Resource Manager to get enabled APIs on each service project
data "google_cloud_asset_resources_search_all" "services" {
  for_each    = local.service_project_ids
  scope       = "projects/${each.key}"
  asset_types = ["serviceusage.googleapis.com/Service"]
  provider    = google-beta
}

locals {
  service_projects = {
    for pid in local.service_project_ids :
    pid => {
      name   = data.google_project.service_projects[pid].name
      number = data.google_project.service_projects[pid].number
      apis = toset(compact(
        [for k in data.google_cloud_asset_resources_search_all.services[pid].results : lookup(k, "display_name", null)]
      ))
    }
  }
  _service_accounts = {
    for k, v in local.service_projects :
    k => compact([
      contains(v.apis, "compute.googleapis.com") ? "${v.number}@cloudservices.gserviceaccount.com" : null,
      contains(v.apis, "compute.googleapis.com") ? "${v.number}-compute@developer.gserviceaccount.com" : null,
      contains(v.apis, "container.googleapis.com") ? "service-${v.number}@container-engine-robot.iam.gserviceaccount.com" : null,
    ])
  }
  service_accounts           = { for k, v in local._service_accounts : k => [for a in v : "serviceAccount:${a}"] }
  give_project_viewer_access = coalesce(var.give_project_viewer_access, false)
}
# Give all Service Accounts Read-only permissions at project level, if enabled
resource "google_project_iam_member" "compute_network_viewer" {
  for_each = toset(flatten([for k, v in local.service_accounts : [for a in v : a] if local.give_project_viewer_access]))
  project  = local.project
  member   = each.value
  role     = "roles/compute.networkViewer"
}

locals {
  gke_service_accounts = { for k, v in local.service_accounts :
    k => one([for a in v : a if strcontains(a, "container-engine-robot")])
  }
}
# Give GKE Service Accounts hostServiceAgentUser role
resource "google_project_iam_member" "gke_host_service_agent_user" {
  for_each = { for k, v in local.gke_service_accounts : k => v if v != null }
  project  = local.project
  member   = each.value
  role     = "roles/container.hostServiceAgentUser"
}


locals {
  shared_subnetworks = { for s in local.subnetworks :
    "${s.region}/${s.name}" => {
      subnetwork = s.id
      region     = s.region
      purpose    = s.purpose
      members = toset(flatten(concat(
        [for service_project_id in lookup(s, "attached_projects", []) : lookup(local.service_accounts, service_project_id, [])],
        [for shared_account in lookup(s, "shared_accounts", []) : trimspace(shared_account)]
      )))
    } if length(lookup(s, "attached_projects", [])) > 0 || length(lookup(s, "shared_accounts", [])) > 0
  }
}
resource "google_compute_subnetwork_iam_binding" "default" {
  for_each   = { for k, v in local.shared_subnetworks : k => v if v.purpose == "PRIVATE" }
  project    = local.project
  region     = each.value.region
  subnetwork = each.value.subnetwork
  members    = each.value.members
  role       = "roles/compute.networkUser"
}

locals {
  shared_gke_subnetworks = { for k, v in local.shared_subnetworks :
    k => merge(v, {
      members = [for m in v.members : m if endswith(m, "container-engine-robot.iam.gserviceaccount.com")]
    })
  }
}
resource "google_compute_subnetwork_iam_binding" "gke" {
  for_each   = { for k, v in local.shared_gke_subnetworks : k => v if v.purpose == "PRIVATE" && length(v.members) > 0 }
  project    = local.project
  region     = each.value.region
  subnetwork = each.value.subnetwork
  members    = each.value.members
  role       = "roles/container.serviceAgent"
}

locals {
  viewable_subnets = { for s in local.subnetworks :
    "${s.region}/${s.name}" => {
      subnetwork = s.id
      region     = s.region
      purpose    = s.purpose
      members    = toset(s.viewer_accounts)
    } if length(lookup(s, "viewer_accounts", [])) > 0
  }
}
resource "google_compute_subnetwork_iam_binding" "viewer" {
  for_each   = { for k, v in local.viewable_subnets : k => v if v.purpose == "PRIVATE" }
  project    = local.project
  region     = each.value.region
  subnetwork = each.value.subnetwork
  members    = each.value.members
  role       = "roles/compute.networkViewer"
}


