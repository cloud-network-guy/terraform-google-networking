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
  service_projects = { for pid in local.service_project_ids :
    pid => {
      name   = data.google_project.service_projects[pid].name
      number = data.google_project.service_projects[pid].number
      apis = toset(compact(
        [for k in data.google_cloud_asset_resources_search_all.services[pid].results : lookup(k, "display_name", null)]
      ))
    }
  }
  service_accounts = { for k, v in local.service_projects :
    k => compact([
      contains(v.apis, "compute.googleapis.com") ? "serviceAccount:${v.number}@cloudservices.gserviceaccount.com" : null,
      contains(v.apis, "compute.googleapis.com") ? "serviceAccount:${v.number}-compute@developer.gserviceaccount.com" : null,
      contains(v.apis, "container.googleapis.com") ? "serviceAccount:service-${v.number}@container-engine-robot.iam.gserviceaccount.com" : null,
    ])
  }
  shared_subnetworks = { for s in local.subnetworks :
    "${var.region}/${s.name}" => {
      subnetwork = s.id
      region     = s.region
      purpose    = s.purpose
      members = toset(flatten(concat(
        [for service_project_id in s.attached_projects : lookup(local.service_accounts, service_project_id, [])],
        [for shared_account in s.shared_accounts : trimspace(shared_account)]
      )))
    } if length(lookup(s, "attached_projects", [])) > 0
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


resource "google_compute_subnetwork_iam_binding" "gke" {
  for_each   = { for k, v in local.shared_subnetworks : k => v if v.purpose == "PRIVATE" }
  project    = local.project
  region     = each.value.region
  subnetwork = each.value.subnetwork
  members    = [for member in each.value.members : member if endswith(member, "container-engine-robot.iam.gserviceaccount.com")]
  role       = "roles/container.serviceAgent"
}

locals {
  viewable_subnets = { for s in local.subnetworks :
    "${var.region}/${s.name}" => {
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

