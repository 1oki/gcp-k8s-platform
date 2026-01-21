# ☁️ GCP Cloud-Native Platform

![Terraform](https://img.shields.io/badge/Terraform-1.9+-623CE4?style=flat&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30+-326CE5?style=flat&logo=kubernetes)
![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?style=flat&logo=argo)
![GCP](https://img.shields.io/badge/Cloud-GCP-4285F4?style=flat&logo=google-cloud)

A production-grade, fully automated infrastructure platform built on **Google Cloud (GKE)**.
This project demonstrates a complete **DevOps lifecycle**, implementing Infrastructure as Code (IaC), GitOps, High Availability, and Disaster Recovery patterns.

---

## 🏗 Architecture Overview

The platform is designed with **security** and **reliability** in mind. It uses VPC-native networking, private subnets, and Workload Identity for passwordless authentication between Kubernetes and GCP services.

```mermaid
graph TD
    User((Internet User)) -->|HTTPS/TLS| CloudDNS[DNS Provider]
    CloudDNS -->|A-Record| GLB[Google Load Balancer]
    
    subgraph "GCP VPC (us-central1)"
        direction TB
        GLB -->|Traffic| Ingress[Nginx Ingress Controller]
        
        subgraph "GKE Cluster"
            Ingress -->|Routing| Service[App Service]
            
            subgraph "Workloads"
                Pod1[Application Pods]
                Pod2[Application Pods]
            end
            
            subgraph "Data Layer (Stateful)"
                Primary[Postgres Primary]
                Replica[Postgres Replica]
                CNPG[CNPG Operator]
            end
            
            Service --> Pod1 & Pod2
            Pod1 & Pod2 -->|Read/Write| Primary
            Primary -.->|Replication| Replica
        end
    end
    
    subgraph "Backup & Recovery"
        Primary -->|WAL Archiving| GCS[Google Cloud Storage]
        GCS -.->|PITR Restore| Primary
    end

    style User fill:#fff,stroke:#333
    style GLB fill:#4285F4,stroke:#fff,color:#fff
    style Ingress fill:#009639,stroke:#fff,color:#fff
    style Primary fill:#336791,stroke:#fff,color:#fff
    style GCS fill:#EA4335,stroke:#fff,color:#fff
```

## 🛠 Tech Stack

| Domain | Technology | Implementation Details |
| :--- | :--- | :--- |
| **Cloud Provider** | Google Cloud Platform | VPC-native GKE, Cloud Router, Cloud NAT, GCS. |
| **IaC** | Terraform | Modular structure, Remote State in GCS with locking, IAM automation. |
| **Orchestration** | Kubernetes (GKE) | Managed Control Plane, Spot Instances for cost optimization. |
| **Package Mgmt** | Helm | Custom charts with subcharts (dependencies). |
| **CI/CD & GitOps** | GitHub Actions + ArgoCD | CI builds Docker images. ArgoCD syncs cluster state with Git. |
| **Database** | PostgreSQL (CloudNativePG) | Operator pattern, HA Cluster, S3 Backups (WAL Archiving). |
| **Security** | Cert-Manager | Automated Let's Encrypt SSL certificates (HTTP-01 challenge). |
| **Observability** | Loki Stack | Centralized logging (Promtail -> Loki -> Grafana). |

## 🚀 Deployment Pipeline (GitOps Flow)

We moved from imperative commands (`kubectl apply`) to a declarative **GitOps** model.

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Git as GitHub Repo
    participant CI as GitHub Actions
    participant Reg as Docker Hub
    participant Argo as ArgoCD
    participant K8s as GKE Cluster

    Dev->>Git: Push Code
    Git->>CI: Trigger Workflow
    CI->>CI: Build & Test
    CI->>Reg: Push Docker Image (Tag: SHA)
    
    par GitOps Sync
        Argo->>Git: Poll for changes
        Argo->>K8s: Detect Drift
        Argo->>K8s: Apply Manifests (Helm)
    end
    
    K8s->>Reg: Pull New Image
    K8s->>K8s: Rolling Update
```

## 📂 Repository Structure

```text
├── terraform/             # Infrastructure as Code
│   ├── main.tf            # Network & Firewall definitions
│   ├── gke.tf             # Kubernetes Cluster configuration
│   ├── iam.tf             # Service Accounts & Workload Identity
│   └── storage.tf         # GCS Buckets for State & Backups
├── k8s/                   # Kubernetes Manifests
│   ├── charts/            # Custom Helm Charts
│   └── argocd/            # ArgoCD Application definitions
├── app/                   # Source Code (Python/Flask)
└── .github/workflows/     # CI Pipelines
```

## ⚡ Getting Started

This repository includes a comprehensive guide to bootstrapping the entire platform from scratch.

### 👉 [Read the Bootstrap Guide](BOOTSTRAP.md)

---
*Created by Sergei Filippov*
