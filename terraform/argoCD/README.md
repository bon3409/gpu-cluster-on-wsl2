# ArgoCD Terraform Deployment

This module deploys ArgoCD to a Kubernetes cluster using the official Helm chart.

## Prerequisites

- Kubernetes cluster access
- Terraform >= 1.5.0
- Helm provider for Terraform

## Usage

```hcl
module "argo_cd" {
  source  = "./modules/argo-cd"
  kubernetes_host = "https://<api-server-ip>:6443"
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `kubernetes_host` | Kubernetes API server host | `string` | required |
| `argo_cd_chart_version` | ArgoCD Helm chart version | `string` | `"5.50.0"` |

## Outputs

| Name | Description |
|------|-------------|
| `argo_cd_server_url` | ArgoCD server URL |
| `argo_cd_namespace` | ArgoCD namespace (`argo-cd`) |