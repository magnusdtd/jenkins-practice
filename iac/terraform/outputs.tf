# GKE Connection
output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.primary.name
}

output "gke_connect_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
}

output "jenkins_ssh_command" {
  description = "SSH command to connect to Jenkins instance"
  value       = "ssh ${split(":", var.user_name)[0]}@${google_compute_instance.instance_jenkins.network_interface[0].access_config[0].nat_ip}"
  sensitive   = true
}

# Jenkins VM Connection
output "jenkins_public_ip" {
  description = "Public IP of Jenkins instance"
  value       = google_compute_instance.instance_jenkins.network_interface[0].access_config[0].nat_ip
}