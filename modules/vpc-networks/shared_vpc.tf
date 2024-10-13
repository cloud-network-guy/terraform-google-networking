# Create list of all service project IDs being shared to
locals {
  service_project_ids = toset(flatten([for i, v in local.subnets : v.attached_projects]))
}

# Enable shared VPC service project for these
resource "google_compute_shared_vpc_service_project" "default" {
  for_each        = { for i, v in local.service_project_ids : "${var.project_id}/${v}" => v }
  host_project    = var.project_id
  service_project = each.value
}

# Retrieve project information for all service projects, given project ID
data "google_project" "service_projects" {
  for_each   = local.service_project_ids
  project_id = each.value
}

# Configure Asset Resource Manage to use Host VPC as quota/billing project
provider "google-beta" {
  user_project_override = true
  billing_project       = coalesce(var.vpc_networks[0].project_id, var.project_id)
}

# Retrieve enabled services (APIs) for all service projects, given project ID
data "google_cloud_asset_resources_search_all" "services" {
  for_each    = local.service_project_ids
  scope       = "projects/${each.value}"
  asset_types = ["serviceusage.googleapis.com/Service"]
  provider    = google-beta
}

locals {
  # Form Map of keyed by Project ID with Project Number & list of enabled services (APIs)
  projects = { for project_id in local.service_project_ids :
    project_id => {
      number = data.google_project.service_projects[project_id].number
      apis   = toset(compact([for _ in data.google_cloud_asset_resources_search_all.services[project_id].results : lookup(_, "display_name", null)]))
    }
  }
  # For each Project ID, create a list of service accounts needing compute.networkUser permissions
  compute_service_accounts = { for k, v in local.projects :
    k => compact([
      contains(v.apis, "compute.googleapis.com") ? "serviceAccount:${v.number}@cloudservices.gserviceaccount.com" : null,
      contains(v.apis, "compute.googleapis.com") ? "serviceAccount:${v.number}-compute@developer.gserviceaccount.com" : null,
    ])
  }
  # Do the same for GKE related service accounts
  gke_service_accounts = { for k, v in local.projects :
    k => compact([
      contains(v.apis, "container.googleapis.com") ? "serviceAccount:service-${v.number}@container-engine-robot.iam.gserviceaccount.com" : null,
    ])
  }
  # Create a list of objects for all subnets that are shared
  shared_subnets = flatten([for k, v in local.subnets :
    {
      subnet_key = v.index_key
      project_id = v.project_id
      region     = v.region
      subnetwork = "projects/${v.project_id}/regions/${v.region}/subnetworks/${v.name}"
      role       = "roles/compute.networkUser"
      members = toset(flatten(concat(
        [for i, service_project_id in v.attached_projects : lookup(local.compute_service_accounts, service_project_id, [])],
        [for i, service_project_id in v.attached_projects : lookup(local.gke_service_accounts, service_project_id, [])],
        v.shared_accounts
      )))
    } if v.is_private == true
  ])
  # Same for viewer
  viewable_subnets = flatten([for k, v in local.subnets :
    {
      subnet_key = v.index_key
      project_id = v.project_id
      region     = v.region
      subnetwork = "projects/${v.project_id}/regions/${v.region}/subnetworks/${v.name}"
      role       = "roles/compute.networkViewer"
      members    = toset(v.viewer_accounts)
    } if v.is_private == true
  ])
}

# Give Compute Network User permissions on the subnet to the applicable accounts
resource "google_compute_subnetwork_iam_binding" "default" {
  for_each   = { for i, v in local.shared_subnets : v.subnet_key => v if length(v.members) > 0 }
  project    = each.value.project_id
  region     = each.value.region
  subnetwork = each.value.subnetwork
  role       = each.value.role
  members    = each.value.members
  depends_on = [google_compute_subnetwork.default]
}

# Give Compute Network Viewer permissions on the subnet to the applicable accounts
resource "google_compute_subnetwork_iam_binding" "viewer" {
  for_each   = { for i, v in local.viewable_subnets : v.subnet_key => v if length(v.members) > 0 }
  project    = each.value.project_id
  region     = each.value.region
  subnetwork = each.value.subnetwork
  role       = each.value.role
  members    = each.value.members
  depends_on = [google_compute_subnetwork.default]
}

locals {
  gke_shared_subnets = [for i, v in local.shared_subnets :
    merge(v, {
      role    = "roles/container.serviceAgent"
      members = toset(flatten(values(local.gke_service_accounts)))
      members = [for i, service_project_id in v.attached_projects :
        lookup(local.gke_service_accounts, service_project_id, [])
      ]
    })
  ]
}

resource "google_compute_subnetwork_iam_binding" "gke" {
  for_each   = { for i, v in local.gke_shared_subnets : v.subnet_key => v if length(v.members) > 0 }
  project    = each.value.project_id
  region     = each.value.region
  subnetwork = each.value.subnetwork
  role       = each.value.role
  members    = each.value.members
  depends_on = [google_compute_subnetwork.default]
}
