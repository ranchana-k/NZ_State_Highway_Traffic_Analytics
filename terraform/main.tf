# main.tf
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.25.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  project = local.envs.TF_VAR_project_id
  region  = local.envs.TF_VAR_region
  zone    = local.envs.TF_VAR_zone
}

# Enable Cloud Run API
resource "google_project_service" "cloudrun" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "data_lake_bucket" {
  name          = local.envs.TF_VAR_storage_bucket_name
  location      = local.envs.TF_VAR_location
  storage_class = "STANDARD"
  uniform_bucket_level_access = true
  versioning {
    enabled     = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30  // days
    }
  }

  force_destroy = true
}

resource "google_bigquery_dataset" "prod_dataset" {
  dataset_id    = local.envs.TF_VAR_bq_dataset_name
  location      = local.envs.TF_VAR_location
}

resource "google_bigquery_dataset" "raw_dataset" {
  dataset_id    = local.envs.TF_VAR_bq_raw_dataset_name
  location      = local.envs.TF_VAR_location
}
# Create the Cloud Run service
resource "google_cloud_run_v2_service" "default" {
  name     = var.app_name
  location = local.envs.TF_VAR_location
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      max_instance_count = 2
    }

    containers {
      image = local.envs.TF_VAR_docker_image
     
      env {
        name = "TF_VAR_project_id"
        value = local.envs.TF_VAR_project_id
      }
      env {
        name = "TF_VAR_region"
        value = local.envs.TF_VAR_zone
      }
      env {
        name = "TF_VAR_location"
        value = local.envs.TF_VAR_location
      }
      env {
        name = "TF_VAR_bq_dataset_name"
        value = local.envs.TF_VAR_bq_dataset_name
      }
      env {
        name = "TF_VAR_bq_raw_dataset_name"
        value = local.envs.TF_VAR_bq_raw_dataset_name
      }
      env {
        name = "TF_VAR_storage_bucket_name"
        value = local.envs.TF_VAR_bq_raw_dataset_name
      }
      env {
        name = "GOOGLE_APPLICATION_CREDENTIALS"
        value = "/home/src/keys/creds.json"
      }
      ports {
        container_port = 6789
      }
      resources {
          limits = {
            cpu    = var.container_cpu
            memory = var.container_memory
          }
      
  }
  }
  }
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

resource "google_cloud_run_v2_service_iam_member" "noauth" {
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "url" {
  value = "${google_cloud_run_v2_service.default.uri}"
}
 