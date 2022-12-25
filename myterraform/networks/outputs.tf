output "network" {
  value       = google_compute_network.vpc
  description = "The VPC"
}

output "subnet" {
  value       = google_compute_subnetwork.subnet
  description = "The subnet"
}
output "management-subnet" {
  value       = google_compute_subnetwork.management-subnet
  description = "The subnet"
}
output "management_subnet_ip" {
  value       = google_compute_subnetwork.management-subnet.ip_cidr_range
  description = "The subnet"
}
output "cluster_master_ip_cidr_range" {
  value       = local.cluster_master_ip_cidr_range
  description = "The CIDR range to use for Kubernetes cluster master"
}

output "cluster_pods_ip_cidr_range" {
  value       = local.cluster_pods_ip_cidr_range
  description = "The CIDR range to use for Kubernetes cluster pods"
}

output "cluster_services_ip_cidr_range" {
  value       = local.cluster_services_ip_cidr_range
  description = "The CIDR range to use for Kubernetes cluster services"
}
