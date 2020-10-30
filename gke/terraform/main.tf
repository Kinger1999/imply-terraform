terraform {
  required_version = ">= 0.12"
  backend "gcs" {}
}

provider "google" {
  version = "3.5.0"
  project = var.project_id
  region  = var.region
}

provider "random" {
  version = "2.3.0"
}

provider "helm" {
  version = "1.2.4"
  kubernetes {
    load_config_file = false

    host  = google_container_cluster.gke.endpoint
    token = data.google_client_config.current.access_token

    cluster_ca_certificate = base64decode(google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
  }
}

provider "kubernetes" {
  version = "1.13.2"

  load_config_file = false

  host  = google_container_cluster.gke.endpoint
  token = data.google_client_config.current.access_token

  cluster_ca_certificate = base64decode(google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}

locals {
  create_vpc  = var.vpc_id == ""
  vpc_id      = local.create_vpc ? google_compute_network.vpc[0].id : var.vpc_id
  cidr_range  = var.cidr_range == "" ? "10.128.0.0/16" : var.cidr_range
  cidr_ranges = cidrsubnets(local.cidr_range, 2, 2, 2)

  location = var.zone == "" ? var.region : var.zone
  is_zonal = var.zone != ""

  create_bucket = var.bucket == ""
  bucket_url    = local.create_bucket ? google_storage_bucket.bucket[0].url : var.bucket
  bucket_name   = local.create_bucket ? google_storage_bucket.bucket[0].name : regex("^gs://(.*)", var.bucket)[0]

  create_sql   = var.sql_endpoint == ""
  sql_endpoint = local.create_sql ? google_sql_database_instance.system[0].private_ip_address : var.sql_endpoint
  sql_password = var.sql_password == "" ? random_password.sql_password[0].result : var.sql_password
  sql_username = var.sql_username == "" ? "imply" : var.sql_username

  deployment_name = "imply-${terraform.workspace}"
  unique_id       = "${local.deployment_name}-${random_id.unique[0].hex}"

  ingress_enabled = var.dns_zone != ""
  subdomain       = terraform.workspace == "default" ? "imply" : local.deployment_name
}

# Get current gcloud config to install helm chart
data "google_client_config" "current" {
}

# Buckets are globally unique so append a random value
# SQL cannot be recreated with the same name within 7 days, so append there too
resource "random_id" "unique" {
  byte_length = 8
  count       = local.create_bucket || local.create_sql ? 1 : 0
}

output "license" {
  value = var.license
}

output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "zone" {
  value = var.zone
}

output "vpc" {
  value = var.vpc_id
}

output "cidr" {
  value = var.cidr_range
}

output "bucket" {
  value = var.bucket
}

output "dns_zone" {
  value = var.dns_zone
}

output "sql_endpoint" {
  value = var.sql_endpoint
}

output "sql_username" {
  value = var.sql_username
}

output "sql_password" {
  value = var.sql_password
}

output "dns_host" {
  value = local.ingress_enabled ? replace(google_dns_record_set.manager[0].name, "/[.]$/", "") : null
}

output "gke_id" {
  value = google_container_cluster.gke.name
}
