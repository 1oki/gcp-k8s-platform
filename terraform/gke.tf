resource "google_container_cluster" "primary" {
  name     = "${var.env_name}-cluster"
  location = "${var.region}-b" 

  # We create the cluster without the default node pool. 
  # Best practice: manage node pools as separate resources to allow 
  # changing nodes without recreating the control plane.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.private.id

  # VPC-native traffic configuration.
  # Using the secondary ranges created in networking module.
  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  # Disable deletion protection for learning purposes (easier 'terraform destroy').
  # In production, this should be set to true.
  deletion_protection = false

  # Workload Identity allows Kubernetes service accounts to act as 
  # Google Cloud IAM service accounts.
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}