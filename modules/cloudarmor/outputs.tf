
output "name" {
  value = local.create ? one(google_compute_security_policy.default).name : null
}

output "id" {
  value = local.create ? one(google_compute_security_policy.default).id : null
}

output "self_link" {
  value = local.create ? one(google_compute_security_policy.default).self_link : null
}

