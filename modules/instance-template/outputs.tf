output "name" { value = local.create ? one(google_compute_instance_template.default).name : null }
output "id" { value = local.create ? one(google_compute_instance_template.default).id : null }
output "self_link" { value = local.create ? one(google_compute_instance_template.default).self_link : null }


