# Generate random password for created MySQL
resource "random_password" "sql_password" {
  length  = 16
  special = false
  count   = local.create_sql ? 1 : 0
}

# MySQL instance, highly available if no zone is specified
resource "google_sql_database_instance" "system" {
  name             = "${local.unique_id}-db"
  database_version = "MYSQL_5_7"
  count            = local.create_sql ? 1 : 0

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier              = "db-n1-standard-2"
    disk_autoresize   = true
    availability_type = local.is_zonal ? "ZONAL" : "REGIONAL"

    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = local.vpc_id
    }
  }
}

# Default User created if we are creating the DB
resource "google_sql_user" "users" {
  name     = "imply"
  instance = google_sql_database_instance.system[0].name
  password = local.sql_password
  count    = local.create_sql ? 1 : 0
}

# Default Database created if we are creating the DB
resource "google_sql_database" "database" {
  name     = "imply-manager"
  instance = google_sql_database_instance.system[0].name
  charset  = "utf8mb4"
  count    = local.create_sql ? 1 : 0
}

# Database alerts
resource "google_monitoring_alert_policy" "rds_alerts" {
  display_name = "${local.deployment_name} SQL Health"
  combiner     = "OR"

  conditions {
    display_name = "CPU >= 80%"
    condition_threshold {
      filter          = <<-EOT
      metric.type="cloudsql.googleapis.com/database/cpu/utilization"
      AND resource.type="cloudsql_database"
      AND resource.labels.database_id="${var.project_id}:${google_sql_database_instance.system[0].id}"
      EOT
      duration        = "0s"
      threshold_value = ".8"
      comparison      = "COMPARISON_GT"
      trigger {
        count = 5
      }
      aggregations {
        per_series_aligner = "ALIGN_MAX"
        alignment_period   = "60s"
      }
    }
  }

  conditions {
    display_name = "Memory >= 80%"
    condition_threshold {
      filter          = <<-EOT
      metric.type="cloudsql.googleapis.com/database/memory/utilization"
      AND resource.type="cloudsql_database"
      AND resource.labels.database_id="${var.project_id}:${google_sql_database_instance.system[0].id}"
      EOT
      duration        = "0s"
      threshold_value = ".8"
      comparison      = "COMPARISON_GT"
      trigger {
        count = 5
      }
      aggregations {
        per_series_aligner = "ALIGN_MAX"
        alignment_period   = "60s"
      }
    }
  }

  conditions {
    display_name = "Disk >= 80%"
    condition_threshold {
      filter          = <<-EOT
      metric.type="cloudsql.googleapis.com/database/disk/utilization"
      AND resource.type="cloudsql_database"
      AND resource.labels.database_id="${var.project_id}:${google_sql_database_instance.system[0].id}"
      EOT
      duration        = "0s"
      threshold_value = ".8"
      comparison      = "COMPARISON_GT"
      trigger {
        count = 5
      }
      aggregations {
        per_series_aligner = "ALIGN_MAX"
        alignment_period   = "60s"
      }
    }
  }

  documentation {
    content = "Please contact Imply Customer Service for next steps."
  }

  count = local.create_sql ? 1 : 0
}
