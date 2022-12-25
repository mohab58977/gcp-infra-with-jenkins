
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  // Only needed if you use a service account key
  project = var.project_id
  region  = var.region
  zone    = var.main_zone
}

module "google_networks" {
  source = "./networks"

  project_id = var.project_id
  region     = var.region
}

module "bastion" {
  source = "./bastion"

  project_id   = var.project_id
  region       = var.region
  zone         = var.main_zone
  bastion_name = "app-cluster"
  network_name = module.google_networks.network.name
  subnet_name  = module.google_networks.management-subnet.name
}


module "google_kubernetes_cluster" {
  source = "./kubernetes_cluster"

  project_id                 = var.project_id
  region                     = var.region
  main_zone                  = var.main_zone
  node_zones                 = var.cluster_node_zones
  network_name               = module.google_networks.network.name
  subnet_name                = module.google_networks.subnet.name
  master_ipv4_cidr_block     = module.google_networks.cluster_master_ip_cidr_range
  pods_ipv4_cidr_block       = module.google_networks.cluster_pods_ip_cidr_range
  services_ipv4_cidr_block   = module.google_networks.cluster_services_ip_cidr_range
  authorized_ipv4_cidr_block = "${module.bastion.ip}/32"
}
