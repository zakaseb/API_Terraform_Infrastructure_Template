resource "google_artifact_registry_repository" "callsign" {
  repository_id = "callsign"
  format        = "DOCKER"
}

module "cloud_run" {
  source  = "GoogleCloudPlatform/cloud-run/google"
  version = "~> 0.12"

  service_name = "callsign"
  project_id   = var.GOOGLE_PROJECT
  location     = var.GOOGLE_REGION
  image        = "${var.GOOGLE_REGION}-docker.pkg.dev/${var.GOOGLE_PROJECT}/${google_artifact_registry_repository.callsign.repository_id}/callsign:${var.app_version}"

  ports = {
    name = "http1"
    port = var.app_port
  }

  service_annotations = {
    "run.googleapis.com/ingress" : "all"
  }

  template_annotations = {
    "autoscaling.knative.dev/maxScale" : 10,
    "autoscaling.knative.dev/minScale" : 1
  }

}


# module "cloud_run" {
#   source  = "GoogleCloudPlatform/cloud-run/google"
#   version = "0.13.0"

#   name                  = "callsign"
#   region                = var.GOOGLE_REGION
#   image                 = google_artifact_registry_repository.callsign.repository_id
#   allow_unauthenticated = true

#   environment_variables = {
#     BUCKET_NAME = google_storage_bucket.callsign.name
#   }

#   min_instances = 1
#   max_instances = 10

#   resources = {
#     limits = {
#       cpu    = "1"
#       memory = "512Mi"
#     }
#   }

#   enable_load_balancer = true

#   iam_roles = {
#     "roles/storage.objectCreator" = "serviceAccount:${module.cloud_run.service_account_email}"
#   }
# }
