# GCP Kubernetes Platform

Reference architecture for a cloud-native infrastructure on Google Cloud Platform.

## Tech Stack
- **Cloud:** Google Cloud Platform (GCP)
- **IaC:** Terraform (Remote State in GCS)
- **Orchestration:** GKE (Google Kubernetes Engine)
- **CI/CD:** GitHub Actions + ArgoCD (GitOps)

## Structure
- `/terraform` - Infrastructure definitions
- `/k8s` - Kubernetes manifests and Helm charts
