# Creation and Management of a Single VPC Network

- Subnets, Secondary Ranges
- IP Ranges and Private Service Access Connections (Netapp, etc)
- Cloud Routers & Cloud NATs
- VPC Peering
- Static Routes

# Inputs 


| Name         | Description                        | Type     | Default |
|--------------|------------------------------------|----------|--|
| project\_id  | Project ID of the GCP project      | `string` | n/a |
| name_prefix |        | `string` | n/a |

# Examples

```
region             = "us-west4"
main_cidrs         = ["10.214.128.0/23"]
gke_pods_cidrs     = ["100.66.0.0/16"]
gke_services_cidrs = ["100.67.0.0/17"]
attached_projects = [
  "otc-ems-fdx1",
]
shared_accounts = [
  "serviceAccount:service-620385009846@container-engine-robot.iam.gserviceaccount.com",
  "serviceAccount:service-77778400620@container-engine-robot.iam.gserviceaccount.com",
]
proxy_only_cidr        = "100.64.240.0/26"
servicenetworking_cidr = "100.64.8.0/21"
netapp_cidr            = "10.1.8.0/21"
```
