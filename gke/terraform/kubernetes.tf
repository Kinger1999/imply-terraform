# Service Account - Manager
resource "google_service_account" "manager" {
  account_id   = "${local.deployment_name}-msa"
  display_name = "Imply Manager Service Account"
  description  = "Service Account used by Imply Manager in ${local.deployment_name}-gke"
}

# Grant the service account the minimum necessary roles and permissions in order to run the GKE cluster
resource "google_project_iam_member" "manager-log_writer" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.manager.email}"
}

resource "google_project_iam_member" "manager-metric_writer" {
  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.manager.email}"
}

resource "google_project_iam_member" "manager-monitoring_viewer" {
  role   = "roles/monitoring.viewer"
  member = "serviceAccount:${google_service_account.manager.email}"
}

# Service Account - Agent
resource "google_service_account" "agent" {
  account_id   = "${local.deployment_name}-asa"
  display_name = "Imply Node Service Account"
  description  = "Service Account used by Imply Clusters in ${local.deployment_name}-gke"
}

# Grant the service account the minimum necessary roles and permissions in order to run the GKE cluster
resource "google_project_iam_member" "agent-log_writer" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.agent.email}"
}

resource "google_project_iam_member" "agent-metric_writer" {
  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.agent.email}"
}

resource "google_project_iam_member" "agent-monitoring_viewer" {
  role   = "roles/monitoring.viewer"
  member = "serviceAccount:${google_service_account.agent.email}"
}

# GKE Cluster
resource "google_container_cluster" "gke" {
  name     = "${local.deployment_name}-gke"
  location = local.location

  network    = local.vpc_id
  subnetwork = google_compute_subnetwork.subnet.id

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = local.cidr_ranges[1]
    services_ipv4_cidr_block = local.cidr_ranges[2]
  }
}

# Node Pool - System
# For running the manager and zookeeper
resource "google_container_node_pool" "system" {
  name     = "system"
  location = local.location
  cluster  = google_container_cluster.gke.name

  # Node count is per region so if using regional you get 3 with a count of 1
  node_count = local.is_zonal ? 3 : 1

  node_config {
    machine_type    = "e2-standard-2"
    service_account = google_service_account.manager.email

    labels = {
      "imply.io/type" = "system"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

# Node Pool - n2-standard-2 (master)
resource "google_container_node_pool" "n2-standard-2" {
  name     = "n2-standard-2"
  location = local.location
  cluster  = google_container_cluster.gke.name

  node_config {
    machine_type    = "n2-standard-2"
    disk_size_gb    = 20
    service_account = google_service_account.agent.email
    taint = [{
      key    = "imply.io/agent"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    labels = {
      "imply.io/type"         = "agent"
      "imply.io/machine_type" = "n2-standard-2"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 100
  }
}

# Node Pool - n2-standard-8 (master)
resource "google_container_node_pool" "n2-standard-8" {
  name     = "n2-standard-8"
  location = local.location
  cluster  = google_container_cluster.gke.name

  node_config {
    machine_type    = "n2-standard-8"
    disk_size_gb    = 20
    service_account = google_service_account.agent.email
    taint = [{
      key    = "imply.io/agent"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    labels = {
      "imply.io/type"         = "agent"
      "imply.io/machine_type" = "n2-standard-8"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 100
  }
}

# Node Pool - n2-standard-16 (master)
resource "google_container_node_pool" "n2-standard-16" {
  name     = "n2-standard-16"
  location = local.location
  cluster  = google_container_cluster.gke.name

  node_config {
    machine_type    = "n2-standard-16"
    disk_size_gb    = 20
    service_account = google_service_account.agent.email
    taint = [{
      key    = "imply.io/agent"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    labels = {
      "imply.io/type"         = "agent"
      "imply.io/machine_type" = "n2-standard-16"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 100
  }
}

# Node Pool - c2-standard-4 (query)
resource "google_container_node_pool" "c2-standard-4" {
  name     = "c2-standard-4"
  location = local.location
  cluster  = google_container_cluster.gke.name

  node_config {
    machine_type    = "c2-standard-4"
    disk_size_gb    = 20
    service_account = google_service_account.agent.email
    taint = [{
      key    = "imply.io/agent"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    labels = {
      "imply.io/type"         = "agent"
      "imply.io/machine_type" = "c2-standard-4"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 100
  }
}

# Node Pool - c2-standard-8 (query)
resource "google_container_node_pool" "c2-standard-8" {
  name     = "c2-standard-8"
  location = local.location
  cluster  = google_container_cluster.gke.name

  node_config {
    machine_type    = "c2-standard-8"
    disk_size_gb    = 20
    service_account = google_service_account.agent.email
    taint = [{
      key    = "imply.io/agent"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    labels = {
      "imply.io/type"         = "agent"
      "imply.io/machine_type" = "c2-standard-8"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 100
  }
}

# Node Pool - c2-standard-16 (query)
resource "google_container_node_pool" "c2-standard-16" {
  name     = "c2-standard-16"
  location = local.location
  cluster  = google_container_cluster.gke.name

  node_config {
    machine_type    = "c2-standard-16"
    disk_size_gb    = 20
    service_account = google_service_account.agent.email
    taint = [{
      key    = "imply.io/agent"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    labels = {
      "imply.io/type"         = "agent"
      "imply.io/machine_type" = "c2-standard-16"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 100
  }
}

# Node Pool - c2-standard-30 (query)
resource "google_container_node_pool" "c2-standard-30" {
  name     = "c2-standard-30"
  location = local.location
  cluster  = google_container_cluster.gke.name

  node_config {
    machine_type    = "c2-standard-30"
    disk_size_gb    = 20
    service_account = google_service_account.agent.email
    taint = [{
      key    = "imply.io/agent"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    labels = {
      "imply.io/type"         = "agent"
      "imply.io/machine_type" = "c2-standard-30"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 100
  }
}

# Node Pool - n2-highmem-4 (data)
resource "google_container_node_pool" "n2-highmem-4" {
  name     = "n2-highmem-4"
  location = local.location
  cluster  = google_container_cluster.gke.name

  node_config {
    machine_type    = "n2-highmem-4"
    disk_size_gb    = 30
    local_ssd_count = 2
    service_account = google_service_account.agent.email
    taint = [{
      key    = "imply.io/agent"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    labels = {
      "imply.io/type"         = "agent"
      "imply.io/machine_type" = "n2-highmem-4"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 100
  }
}

# Node Pool - n2-highmem-8 (data)
resource "google_container_node_pool" "n2-highmem-8" {
  name     = "n2-highmem-8"
  location = local.location
  cluster  = google_container_cluster.gke.name

  node_config {
    machine_type    = "n2-highmem-8"
    disk_size_gb    = 30
    local_ssd_count = 4
    service_account = google_service_account.agent.email
    taint = [{
      key    = "imply.io/agent"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    labels = {
      "imply.io/type"         = "agent"
      "imply.io/machine_type" = "n2-highmem-8"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 100
  }
}

# Node Pool - n2-highmem-16 (data)
resource "google_container_node_pool" "n2-highmem-16" {
  name     = "n2-highmem-16"
  location = local.location
  cluster  = google_container_cluster.gke.name

  node_config {
    machine_type    = "n2-highmem-16"
    disk_size_gb    = 30
    local_ssd_count = 8
    service_account = google_service_account.agent.email
    taint = [{
      key    = "imply.io/agent"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    labels = {
      "imply.io/type"         = "agent"
      "imply.io/machine_type" = "n2-highmem-16"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 100
  }
}

# Node Pool - n1-highmem-32 (data)
resource "google_container_node_pool" "n1-highmem-32" {
  name     = "n1-highmem-32"
  location = local.location
  cluster  = google_container_cluster.gke.name

  node_config {
    machine_type    = "n1-highmem-32"
    disk_size_gb    = 30
    local_ssd_count = 16
    service_account = google_service_account.agent.email
    taint = [{
      key    = "imply.io/agent"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    labels = {
      "imply.io/type"         = "agent"
      "imply.io/machine_type" = "n1-highmem-32"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 100
  }
}

# Create require role binding to allow the default service account
# to administer resources in the default namespace. This allows the
# manager to make kubernetes calls to CRUD required resources.
resource "kubernetes_role_binding" "default_admin" {
  metadata {
    name = "imply-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "default"
  }
}

resource "kubernetes_secret" "pull_secrets" {
  count = var.pull_secret_username != null ? 1 : 0

  metadata {
    name = "regcred"
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "${base64encode("${var.pull_secret_username}:${var.pull_secret_password}")}"
    }
  }
}
DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"
}

# Helm Release
resource "helm_release" "manager" {
  name       = local.deployment_name
  repository = var.helm_repository
  chart      = "imply"
  version    = var.helm_chart_version
  timeout    = 600

  depends_on = [google_container_node_pool.system]

  values = [
    templatefile("${path.root}/values.yaml.tpl", {
      license             = var.license,
      dataInstanceTypes   = file("${path.root}/config/dataInstanceTypes.json"),
      queryInstanceTypes  = file("${path.root}/config/queryInstanceTypes.json"),
      masterInstanceTypes = file("${path.root}/config/masterInstanceTypes.json"),
      druidInstanceConfig = file("${path.root}/config/druidInstanceTypeConfigurationsVersioned.json")
    })
  ]

  set {
    name  = "manager.metadataStore.host"
    value = local.sql_endpoint
  }

  set {
    name  = "manager.metadataStore.user"
    value = local.sql_username
  }

  set_sensitive {
    name  = "manager.metadataStore.password"
    value = local.sql_password
  }

  set {
    name  = "druid.metadataStore.host"
    value = local.sql_endpoint
  }

  set {
    name  = "druid.metadataStore.user"
    value = local.sql_username
  }

  set_sensitive {
    name  = "druid.metadataStore.password"
    value = local.sql_password
  }

  set {
    name  = "druid.deepStorage.path"
    value = local.bucket_url
  }

  set {
    name  = "zookeeper.replicaCount"
    value = 3
  }

  set {
    name  = "manager.kubernetesMode.helmChartLocation"
    value = "${var.helm_repository}/imply-${var.helm_chart_version}.tgz"
  }

  set {
    name  = "ingress.enabled"
    value = local.ingress_enabled
  }

  set {
    name  = local.ingress_enabled ? "ingress.manager.host" : ""
    value = local.ingress_enabled ? replace(google_dns_record_set.manager[0].name, "/[.]$/", "") : ""
  }

  set {
    name  = local.ingress_enabled ? "ingress.annotations.kubernetes\\.io/ingress\\.global-static-ip-name" : ""
    value = local.ingress_enabled ? google_compute_global_address.ingress_ip[0].name : ""
  }

  set {
    name  = "manager.service.enabled"
    value = local.ingress_enabled
  }

  set {
    name  = "manager.service.type"
    value = "NodePort"
  }

  set {
    name  = var.manager_tag != "" ? "images.manager.tag" : ""
    value = var.manager_tag
  }
}
