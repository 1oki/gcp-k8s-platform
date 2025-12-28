# Service Account for GKE Nodes.
# Nodes should have minimum permissions, not the default Compute Engine permissions.
resource "google_service_account" "kubernetes" {
  account_id   = "kubernetes-sa"
  display_name = "Kubernetes Nodes Service Account"
}

resource "google_container_node_pool" "primary_nodes" {
  name     = "${var.env_name}-node-pool"
  location   = "${var.region}-a"
  cluster  = google_container_cluster.primary.name

  # Initial node count per zone.
  node_count = 1

  node_config {
    # Spot instances (Preemptible) are significantly cheaper (60-90% off).
    # Google can reclaim them at any time, but K8s handles this gracefully.
    preemptible = true

    # e2-medium (2 vCPU, 4GB RAM) is the minimum recommended for GKE 
    # to run system pods + workloads.
    machine_type = "e2-medium"

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = var.env_name
    }

    tags = ["k8s-node"]
  }
}