output "name" { value = local.create ? one(google_compute_service_attachment.default).name : null }
