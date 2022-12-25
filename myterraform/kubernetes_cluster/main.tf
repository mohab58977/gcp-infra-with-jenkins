

resource "google_container_cluster" "app_cluster" {
  name     = "app-cluster"
  location = var.main_zone
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1



  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pods_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }
  network    = var.network_name
  subnetwork = var.subnet_name

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.authorized_ipv4_cidr_block
    }
  }

  # dynamic "master_authorized_networks_config" {
  #   for_each = var.authorized_ipv4_cidr_block != null ? [var.authorized_ipv4_cidr_block] : []
  #   content {
  #     cidr_blocks {
  #       cidr_block   = master_authorized_networks_config.value
  #       display_name = "External Control Plane access"
  #     }
  #   }
  # }

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }
}

# cluster node configurations
resource "google_container_node_pool" "app_cluster_linux_node_pool" {
  name           = "${google_container_cluster.app_cluster.name}--linux-node-pool"
  location       = google_container_cluster.app_cluster.location
  node_locations = var.node_zones
  cluster        = google_container_cluster.app_cluster.name
  node_count     = 1

  node_config {
    machine_type    = "e2-medium"

    service_account = google_service_account.gke-sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
    labels = {
      cluster = google_container_cluster.app_cluster.name
    }
    metadata = {
      // Set metadata on the VM to supply more entropy.
      google-compute-enable-virtio-rng = "true"
      // Explicitly remove GCE legacy metadata API endpoint.
      disable-legacy-endpoints = "true"
    }
  }


}
#create a service account and assign a storage.admin role to give the authority to GKE cluster
resource "google_service_account" "gke-sa" {
  account_id   = "gke-sa"
  display_name = "GKE Service Account"
}

resource "google_project_iam_binding" "gke-sa-binding" {
  project = var.project_id
  role    = "roles/storage.admin"
  members = ["serviceAccount:${google_service_account.gke-sa.email}"]

}
# resource "google_project_iam_binding" "gke-sa-binding2" {
#   project = var.project_id
#   role    = "roles/container.admin"
#   members = ["serviceAccount:${google_service_account.gke-sa.email}"]

# }
