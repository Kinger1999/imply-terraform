# VPC
# Optionally craeted if no vpc_id is specified
resource "google_compute_network" "vpc" {
  name                    = "${local.deployment_name}-vpc"
  auto_create_subnetworks = false
  count                   = local.create_vpc ? 1 : 0
}

# Subnets
# Always created for GKE usage based on supplied CIDR
resource "google_compute_subnetwork" "subnet" {
  name          = "${local.deployment_name}-subnet"
  ip_cidr_range = local.cidr_ranges[0]
  network       = local.vpc_id
}


# Private IP Block
# Used for peering to Google Services (SQL/Storage)
# Only created if we are creating the VPC
resource "google_compute_global_address" "private_ip_address" {
  name          = "${local.deployment_name}-pia"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = local.vpc_id
  count         = local.create_vpc ? 1 : 0
}

# Private VPC Connection
# Used for peering to Google Services (SQL/Storage)
# Only created if we are creating the VPC
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = local.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address[0].name]
  count                   = local.create_vpc ? 1 : 0
}

# Static IP address to be used by the Ingress if configured.
resource "google_compute_global_address" "ingress_ip" {
  name  = "${local.deployment_name}-ingress"
  count = local.ingress_enabled ? 1 : 0
}

data "google_dns_managed_zone" "manager" {
  name  = var.dns_zone
  count = local.ingress_enabled ? 1 : 0
}

# DNS Record for the Ingress controller, if configured.
resource "google_dns_record_set" "manager" {
  name  = "${local.subdomain}.${data.google_dns_managed_zone.manager[0].dns_name}"
  type  = "A"
  ttl   = 300
  count = local.ingress_enabled ? 1 : 0

  managed_zone = data.google_dns_managed_zone.manager[0].name

  rrdatas = [google_compute_global_address.ingress_ip[0].address]
}
