resource "helm_release" "argo-cd" {
  name       = "argo-cd"
  namespace  = "argo-cd"
  create_namespace = true
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = var.argo_cd_chart_version
}