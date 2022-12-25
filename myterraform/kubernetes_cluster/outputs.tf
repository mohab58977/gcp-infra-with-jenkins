
output "name" {
  value = google_container_cluster.app_cluster.name
  description = "The Kubernetes cluster name."
}
output "connect-command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.app_cluster.name} --zone ${google_container_cluster.app_cluster.location} --project ${var.project_id}"
  description = "The Kubernetes cluster name."
}
