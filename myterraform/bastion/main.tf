locals {
  hostname = format("%s-bastion", var.bastion_name)
}


# create a service account and assign a container.admin role to give the authority to management vm to communicate with GKE cluster
resource "google_service_account" "manage-sa" {
  account_id   = format("%s-bastion-sa", var.bastion_name)
  display_name = "GKE Bastion Service Account"
}
resource "google_project_iam_binding" "manage-sa-binding" {
  project = var.project_id
  role    = "roles/storage.admin"
  members = ["serviceAccount:${google_service_account.manage-sa.email}"]

}

resource "google_project_iam_binding" "manage-sa-bindig-2" {
  project = var.project_id
  role    = "roles/container.admin"
  members = ["serviceAccount:${google_service_account.manage-sa.email}"]

}


// Allow access to the Bastion Host via SSH.
resource "google_compute_firewall" "bastion-ssh" {
  name          = format("%s-bastion-ssh", var.bastion_name)
  network       = var.network_name
  direction     = "INGRESS"
  project       = var.project_id
  source_ranges = ["35.235.240.0/20"] // TODO: Restrict further.

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["bastion"]
}

// The user-data script on Bastion instance provisioning.
data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y kubectl
  sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
  export USE_GKE_GCLOUD_AUTH_PLUGIN=True
  sudo -i
  apt update &&  apt -y upgrade &&  apt install -y curl
  apt-get update &&  apt-get install -y lsb-release
  curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
  echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
  apt-get update &&  apt-get install -y docker-ce-cli docker-ce

  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | \
  tee /usr/share/keyrings/helm.gpg > /dev/null
  apt-get install apt-transport-https --yes
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] \
  https://baltocdn.com/helm/stable/debian/ all main" | \
  tee /etc/apt/sources.list.d/helm-stable-debian.list 
  apt-get update && apt-get install helm
  exit
  helm repo add my-repo https://charts.bitnami.com/bitnami
  helm install my-release   --set jenkinsUser=admin   --set jenkinsPassword=password   my-repo/jenkins
  EOF
}

// The Bastion host.
resource "google_compute_instance" "bastion" {


  name         = local.hostname
  machine_type = "e2-micro"
  zone         = var.zone
  project      = var.project_id
  tags         = ["bastion"]



  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }


  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  // Install on startup.
  metadata_startup_script = data.template_file.startup_script.rendered

  network_interface {
    subnetwork = var.subnet_name
  }

  // Allow the instance to be stopped by Terraform when updating configuration.
  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.manage-sa.email
    scopes = ["cloud-platform"]
  }

  /* local-exec providers may run before the host has fully initialized.
  However, they are run sequentially in the order they were defined.
  This provider is used to block the subsequent providers until the instance is available. */
  provisioner "local-exec" {
    command = <<EOF
        READY=""
        for i in $(seq 1 20); do
          if gcloud compute ssh ${local.hostname} --project ${var.project_id} --zone ${var.region}-a --command uptime; then
            READY="yes"
            break;
          fi
          echo "Waiting for ${local.hostname} to initialize..."
          sleep 10;
        done
        if [[ -z $READY ]]; then
          echo "${local.hostname} failed to start in time."
          echo "Please verify that the instance starts and then re-run `terraform apply`"
          exit 1
        fi
EOF
  }

}
