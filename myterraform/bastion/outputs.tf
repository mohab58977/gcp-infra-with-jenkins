output "ip" {
  value       = google_compute_instance.bastion.network_interface.0.network_ip
  description = "The IP address of the Bastion instance."
}

output "ssh" {
  description = "GCloud ssh command to connect to the Bastion instance."
  value = "gcloud compute ssh --zone ${google_compute_instance.bastion.zone} ${google_compute_instance.bastion.name}  --tunnel-through-iap --project ${google_compute_instance.bastion.project} "
  }


output "kubectl_command" {
  description = "kubectl command using the local proxy once the Bastion ssh command is running."
  value       = "HTTPS_PROXY=localhost:8888 kubectl"
}
#gcloud compute ssh --zone "europe-west3-b" "app-cluster-bastion"  --tunnel-through-iap --project "mohab-372519"

