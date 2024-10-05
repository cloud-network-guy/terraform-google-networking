locals {
  upload_ssl_certs = length(coalesce(var.ssl_certs, [])) > 0 ? true : false
  ssl_cert_names   = coalesce(var.ssl_cert_names, [])
  use_ssc          = local.is_http ? coalesce(var.use_ssc, !local.upload_ssl_certs && var.ssl_cert_names == null ? true : false) : false
  use_gmc          = local.is_http && local.is_global ? coalesce(var.use_gmc, false) : false
  ssc_valid_years  = coalesce(var.ssc_valid_years, 5)
  ssc_ca_org       = coalesce(var.ssc_ca_org, "Honest Achmed's Used Cars and Certificates")
  certs_to_upload = local.upload_ssl_certs ? [for i, v in coalesce(var.ssl_certs, []) : {
    name = replace(coalesce(v.name, element(split(".", v.certificate), 0)), "_", "-")
    # If cert and key lengths are under 256 bytes, we assume they are the file names
    certificate = length(v.certificate) < 256 ? file("./${v.certificate}") : v.certificate
    private_key = length(v.private_key) < 256 ? file("./${v.private_key}") : v.private_key
    description = coalesce(v.description, "Uploaded via Terraform")
  }] : length(local.ssl_cert_names) > 0 ? [] : [{ name = "self-signed", description = "For temporary use only" }]
}

# For self-signed, create a private key
resource "tls_private_key" "default" {
  count     = local.is_http && local.use_ssc ? 1 : 0
  algorithm = var.key_algorithm
  rsa_bits  = var.key_bits
}
# Then generate a self-signed cert off that private key
resource "tls_self_signed_cert" "default" {
  count           = local.is_http && local.use_ssc ? 1 : 0
  private_key_pem = one(tls_private_key.default).private_key_pem
  subject {
    common_name  = var.domains != null ? var.domains[0] : "localhost.localdomain"
    organization = local.ssc_ca_org
  }
  validity_period_hours = 24 * 365 * local.ssc_valid_years
  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]
}

# Upload Global SSL Certs
resource "google_compute_ssl_certificate" "default" {
  for_each    = local.is_http && local.is_global ? { for i, v in local.certs_to_upload : v.name => v } : {}
  project     = var.project_id
  description = each.value.description
  name        = local.use_ssc ? null : each.key
  name_prefix = local.use_ssc ? local.name_prefix : null
  certificate = local.use_ssc ? one(tls_self_signed_cert.default).cert_pem : each.value.certificate
  private_key = local.use_ssc ? one(tls_private_key.default).private_key_pem : each.value.private_key
  lifecycle {
    create_before_destroy = false
    ignore_changes        = [certificate, private_key]
  }
}

# Upload Regional SSL Certs
resource "google_compute_region_ssl_certificate" "default" {
  for_each    = local.is_http && local.is_regional ? { for i, v in local.certs_to_upload : v.name => v } : {}
  project     = var.project_id
  description = each.value.description
  name        = local.use_ssc ? null : each.key
  name_prefix = local.use_ssc ? local.name_prefix : null
  certificate = local.use_ssc ? one(tls_self_signed_cert.default).cert_pem : each.value.certificate
  private_key = local.use_ssc ? one(tls_private_key.default).private_key_pem : each.value.private_key
  lifecycle {
    create_before_destroy = false
    ignore_changes        = [certificate, private_key]
  }
  region = local.region
}

# Google-Managed SSL certificates (Global only)
resource "google_compute_managed_ssl_certificate" "default" {
  count = local.is_http && local.is_global && local.use_gmc ? 1 : 0
  name  = local.name_prefix
  managed {
    domains = var.domains
  }
  project = var.project_id
}
