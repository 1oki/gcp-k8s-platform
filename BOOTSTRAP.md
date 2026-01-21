# 📘 Cloud-Native Platform Bootstrap Guide

This guide details the process of bootstrapping the entire infrastructure and application stack from scratch. It assumes you are starting with a clean GCP project.

**Prerequisites:**
1.  **Google Cloud Project:** A dedicated GCP project with billing enabled.
2.  **Domain Name:** A registered domain (e.g., `example.com`) with DNS management access.
3.  **Tooling:** `terraform`, `gcloud`, `kubectl`, `helm` installed on your workstation.

---

## 🏗 Phase 1: Infrastructure Provisioning (Terraform)

Navigate to the terraform directory:
```bash
cd terraform
```

### 1. Configure Variables
Create a `terraform.tfvars` file (do not commit this file!) with your specific values:

```hcl
project_id = "YOUR_GCP_PROJECT_ID"  # Run `gcloud config get-value project`
region     = "us-central1"          # Recommended region
env_name   = "production"           # Resource prefix
```

### 2. Setup Remote State Bucket
Create a GCS bucket to store Terraform state securely. Replace `<UNIQUE_BUCKET_NAME>` with a globally unique name.

```bash
export TF_STATE_BUCKET="<UNIQUE_BUCKET_NAME>"
gcloud storage buckets create gs://$TF_STATE_BUCKET --location=us-central1
gcloud storage buckets update gs://$TF_STATE_BUCKET --versioning
```
*Update `provider.tf` with this bucket name.*

### 3. Deploy Infrastructure
This will create the VPC, GKE Cluster, Node Pool, and Service Accounts with correct IAM bindings.

```bash
terraform init
terraform apply
# Confirm with 'yes'
```
*Wait ~15 minutes for the cluster to be ready.*

---

## ⚙️ Phase 2: Cluster Bootstrap (Helm)

### 1. Authenticate to Cluster
Configure `kubectl` to communicate with the new cluster.

```bash
# Update with your cluster name, zone, and project ID
gcloud container clusters get-credentials <CLUSTER_NAME> \
  --zone <ZONE> \
  --project <PROJECT_ID>

# Verify connection
kubectl get nodes
```

### 2. Install Core Stack
We use Helm to install system components in a specific order.

```bash
# Add Helm Repositories
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add cnpg https://cloudnative-pg.io/charts
helm repo add jetstack https://charts.jetstack.io
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 1. Ingress Controller (L7 Load Balancer)
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer

# 2. Cert-Manager (SSL Certificates)
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.3 \
  --set installCRDs=true

# 3. CloudNativePG Operator (PostgreSQL Management)
helm upgrade --install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace

# 4. Loki Stack (Centralized Logging)
helm upgrade --install loki grafana/loki-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.enabled=true \
  --set prometheus.enabled=false

# 5. ArgoCD (GitOps Controller)
kubectl create namespace argocd
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --version 6.0.0
```

---

## 🌐 Phase 3: External Access Configuration

### 1. Update DNS Records
Wait for the Load Balancer IP to be assigned.

```bash
kubectl get svc -n ingress-nginx -w
```
**Action:** Copy the `EXTERNAL-IP`.
Go to your DNS provider and create two **A Records**:
*   `app.<your-domain>` -> `EXTERNAL-IP` (Main Application)
*   `argocd.<your-domain>` -> `EXTERNAL-IP` (ArgoCD UI)

### 2. Configure Ingress & Certificates
Apply the ClusterIssuer (for Let's Encrypt) and Ingress rules for ArgoCD.

*Update `k8s/argocd/cluster-issuer.yaml` with your email address first.*

```bash
# Apply Certificate Issuer
kubectl apply -f k8s/argocd/cluster-issuer.yaml

# Apply Ingress for ArgoCD
kubectl apply -f k8s/argocd/ingress.yaml
```

---

## 🚀 Phase 4: Application Deployment (GitOps)

Trigger the GitOps workflow. This tells ArgoCD to sync the cluster state with this Git repository.

1.  Open `k8s/argocd/spiral-app.yaml`.
2.  Ensure `repoURL` points to **your fork** of this repository.
3.  Apply the manifest:

```bash
kubectl apply -f k8s/argocd/spiral-app.yaml
```

ArgoCD will now automatically deploy:
*   The Application (Helm Chart)
*   PostgreSQL Cluster (CNPG)
*   Ingress rules

---

## 🕵️‍♂️ Phase 5: Verification

### 1. Access Application
Open `https://app.<your-domain>` in your browser.
*   **Expected:** "Hello from Postgres... Visit count: 1".
*   **Check:** Verify the padlock icon (SSL/TLS is working).

### 2. Access ArgoCD
Open `https://argocd.<your-domain>`.
*   **Username:** `admin`
*   **Password:** Retrieve using:
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
    ```

### 3. Verify Backups
Test if the database can write backups to the GCS bucket (IAM verification).

```bash
# Create a manual backup
cat <<EOF | kubectl apply -f -
apiVersion: postgresql.cnpg.io/v1
kind: Backup
metadata:
  name: manual-backup-check
spec:
  cluster:
    name: spiral-app-db # Ensure this matches your DB cluster name
EOF

# Watch status
kubectl get backups -w
```
*   **Expected:** Phase changes to `completed`.
*   **Verify:** Check your GCS bucket in Google Cloud Console for new files.
