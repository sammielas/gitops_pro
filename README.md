### **Overview**
This is a **GitOps-based continuous deployment system** that demonstrates a complete CI/CD pipeline using modern cloud-native tools. The project deploys a simple Flask application to Kubernetes using ArgoCD for GitOps automation.

---

## **Tech Stack**

### **Application Layer**
- **Python 3.9** with **Flask** - Simple web server returning current time
- **Docker** - Containerization (Python 3.9-slim base image)
- **Port**: 8086 (application), 8085 (Kubernetes service)

### **Infrastructure & Orchestration**
- **Kubernetes** - Container orchestration (via Minikube)
- **Minikube** - Local Kubernetes cluster (Docker driver, profile: `gitops-pro`)
- **Helm 3** - Kubernetes package manager
- **Terraform** - Infrastructure as Code (local backend)

### **GitOps & CI/CD**
- **ArgoCD** - GitOps continuous delivery tool
- **GitHub Actions** - CI pipeline automation
- **Docker Hub** - Container registry (`sammielas/gitopspro`)

---

## **Architecture Pattern: GitOps Pull-Based Deployment**

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   GitHub    │─────▶│ GitHub       │─────▶│ Docker Hub  │
│   (Push)    │      │ Actions CI   │      │  (Image)    │
└─────────────┘      └──────────────┘      └─────────────┘
                            │                      ▲
                            │ Updates              │
                            ▼ values.yaml          │
                     ┌──────────────┐              │
                     │  Git Repo    │              │
                     │  (Source of  │              │
                     │   Truth)     │              │
                     └──────────────┘              │
                            │                      │
                            │ Monitors             │
                            ▼                      │
                     ┌──────────────┐              │
                     │   ArgoCD     │──────────────┘
                     │  (Pulls &    │    Pulls Image
                     │   Syncs)     │
                     └──────────────┘
                            │
                            ▼
                     ┌──────────────┐
                     │  Kubernetes  │
                     │  (Minikube)  │
                     └──────────────┘
```

---

## **Directory Structure**

```
gitops_pro/
├── app.py                      # Flask application entry point
├── Dockerfile                  # Container build definition
├── argocd-app.yaml            # ArgoCD Application manifest
│
├── .github/workflows/
│   └── ci.yaml                # CI pipeline: build → push → update Helm
│
├── gitops-pro-app/            # Helm chart (ArgoCD watches this)
│   ├── Chart.yaml             # Helm chart metadata
│   ├── values.yaml            # Configuration (image tag updated by CI)
│   └── templates/             # Kubernetes manifests
│       ├── deployment.yaml    # Pod deployment spec
│       ├── service.yaml       # Service (NodePort)
│       ├── ingress.yaml       # Ingress rules
│       ├── serviceaccount.yaml
│       ├── hpa.yaml           # Horizontal Pod Autoscaler
│       └── _helpers.tpl       # Helm template helpers
│
└── terraform-configs/         # Infrastructure provisioning
    ├── main.tf                # Minikube installation/startup
    ├── argocd.tf              # ArgoCD Helm deployment
    ├── provider.tf            # Kubernetes/Helm providers
    ├── backend.tf             # Local state storage
    └── *.ps1                  # PowerShell scripts (Windows)
```

---

## **Key Components**

### **1. Application (`app.py`)**
- **Entry Point**: Flask server on `0.0.0.0:8086`
- **Endpoint**: `GET /` returns current server time
- **Dependencies**: Flask (installed in Dockerfile)

### **2. CI Pipeline (`.github/workflows/ci.yaml`)**
Triggers on push to `main`:
1. Builds Docker image with short SHA tag (7 chars)
2. Pushes to Docker Hub
3. Updates `gitops-pro-app/values.yaml` with new image tag
4. Commits and pushes changes back to repo

**Critical Pattern**: The CI pipeline modifies the Git repo, which triggers ArgoCD to sync.

### **3. Helm Chart (`gitops-pro-app/`)**
- **Current Image**: `sammielas/gitopspro:6785fdb`
- **Service Type**: NodePort (port 8085)
- **Features Disabled**: Ingress, ServiceAccount, Autoscaling
- **ArgoCD Sync**: Automated with `prune: true` and `selfHeal: true`

### **4. ArgoCD Configuration (`argocd-app.yaml`)**
- **Source**: This GitHub repo (`gitops_pro`)
- **Path**: `gitops-pro-app/` (Helm chart)
- **Destination**: `default` namespace in local cluster
- **Sync Policy**: Fully automated (self-healing enabled)

### **5. Terraform Infrastructure (`terraform-configs/`)**
- **Minikube Setup**: Installs and starts Minikube with Docker driver
- **ArgoCD Deployment**: Installs ArgoCD via Helm chart
- **Platform**: Windows (PowerShell scripts)
- **State**: Local backend (`terraform.tfstate`)

---

## **Critical Patterns & Conventions**

### **GitOps Workflow**
1. Developer pushes code to `main`
2. GitHub Actions builds image with SHA-based tag
3. CI updates `values.yaml` with new tag
4. ArgoCD detects Git change and syncs to cluster
5. Kubernetes pulls new image and updates deployment

### **Image Tagging Strategy**
- Uses **short Git SHA** (7 characters) for traceability
- Example: `sammielas/gitopspro:6785fdb`
- Enables rollback by reverting `values.yaml`

### **Secrets Management**
Required GitHub Secrets:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `PAT_TOKEN` (Personal Access Token for Git push)

### **Helm Templating**
- Uses standard Helm helpers (`_helpers.tpl`)
- Values override pattern for configuration
- Container port mismatch: app uses 8086, service exposes 8085

---

## **Getting Started**

### **Prerequisites**
- Docker
- Terraform
- kubectl
- Helm 3
- Minikube (or Terraform will install it)

### **Local Development**
```bash
# Run Flask app locally
python app.py
# Access at http://localhost:8086

# Build Docker image
docker build -t gitopspro:local .
docker run -p 8086:8086 gitopspro:local
```

### **Infrastructure Setup**
```bash
cd terraform-configs
terraform init
terraform apply  # Installs Minikube + ArgoCD
```

### **Deploy with ArgoCD**
```bash
kubectl apply -f argocd-app.yaml
# ArgoCD will sync the Helm chart automatically
```

### **Access Application**
```bash
minikube service gitops-pro-app --profile=gitops-pro
```

---

