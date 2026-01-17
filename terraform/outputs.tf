# outputs.tf

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "region" {
  value       = var.region
  description = "GCP Region"
}

output "backup_service_account_email" {
  description = "Email of the Postgres Backup Service Account"
  value       = google_service_account.postgres_backup.email
}