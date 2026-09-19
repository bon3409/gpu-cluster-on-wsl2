# output "argo_cd_server_url" {
#   description = "ArgoCD server URL"
#   value       = helm_release.argo-cd.rendered_args["server.service.type"]
# }

output "argo_cd_namespace" {
  description = "ArgoCD namespace"
  value       = "argo-cd"
}