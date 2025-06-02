variable "credentials" {
  description = "Path to the GCP service account key file"
  type        = string
  sensitive   = true
  default     = "../secrets/jenkins-practice-461513-95aff8dc117a.json"
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "jenkins-practice-461513"
}

variable "region" {
  description = "GCP Region for resources"
  type        = string
  default     = "asia-southeast1-a"
}

variable "GKE_enable_autopilot" {
  description = "GCP Autopilot mode"
  type        = bool
  default     = false
}

variable "GKE_initial_node_count" {
  description = "GCP Initial node count"
  type        = number
  default     = 3
}

variable "network_name" {
  description = "Name of the network to use"
  type        = string
  default     = "default"
}

variable "allowed_ports" {
  description = "List of allowed ports for the firewall"
  type        = list(string)
  default     = ["8080", "50000"]
}

variable "source_ranges" {
  description = "Source IP ranges allowed to access the firewall"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "jenkins-server"
}

variable "machine_type_instance" {
  description = "Machine type for the compute instance"
  type        = string
  default     = "e2-standard-2" // 2 vCPUs, 8 GB RAM
}

variable "machine_disk_size" {
  description = "Machine disk size"
  type        = number
  default     = 50
}

variable "zone" {
  description = "Zone for the compute instance"
  type        = string
  default     = "us-central1-a"
}

variable "firewall_name" {
  description = "Name of the firewall"
  type        = string
  default     = "jenkins-firewall"
}

variable "boot_disk_image" {
  description = "Image for the boot disk"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "boot_disk_size" {
  description = "Size of the boot disk"
  type        = number
  default     = 50
}

variable "user_name" {
  description = "Username for SSH access"
  type        = string
  sensitive   = true
  default     = "magnusdtd"
}
