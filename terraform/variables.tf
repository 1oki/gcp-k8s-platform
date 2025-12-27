variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-southeast1"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "spiral-cluster"
}

variable "env_name" {
  description = "Environment tag (e.g. prod, dev, spiral-c2)"
  type        = string
  default     = "spiral-c2"       
}