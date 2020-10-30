variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
}

variable "zone" {
  description = "Google Cloud Zone, will create regional resources if not set."
  type        = string
}

variable "vpc_id" {
  description = "Google Cloud VPC ID, will be created if not set."
  type        = string
}

variable "cidr_range" {
  description = "CIDR Range Imply should use within the VPC. Will default to 10.128.0.0/16 if not set."
  type        = string
}

variable "bucket" {
  description = "Google Cloud Bucket (eg: gs://imply-cloud-123), will be created if not set."
  type        = string
}

variable "dns_zone" {
  description = "Google Cloud DNS Zone ID. Will setup ingress and a subdomain on the specified zone if set."
  type        = string
}

variable "sql_endpoint" {
  description = "Hostname/IP of an existing MySQL database, will be created if not set."
  type        = string
}

variable "sql_username" {
  description = "Username to authenticate to the SQL DB. Defaults to imply if not set."
  type        = string
}

variable "sql_password" {
  description = "Password to authenticated to the SQL DB, if unset and no endpoint is set will be generated."
  type        = string
}

variable "license" {
  description = "Imply License Key, leave blank for trial mode."
  type        = string
}

variable "helm_chart_version" {
  description = "Used for internal testing only."
  default     = "0.4.5-rc1"
  type        = string
}

variable "pull_secret_username" {
  description = "Used for internal testing only."
  default     = null
  type        = string
}

variable "pull_secret_password" {
  description = "Used for internal testing only."
  default     = null
  type        = string
}

variable "helm_repository" {
  description = "Used for internal testing only."
  default     = "https://static.imply.io/onprem/helm"
  type        = string
}

variable "manager_tag" {
  description = "Used for internal testing only."
  default     = ""
  type        = string
}
