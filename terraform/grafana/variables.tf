variable "grafana_url" {
  type    = string
  default = "http://localhost:3000"
}


variable "grafana_auth" {
  type        = string
  default     = "admin:admin"
  description = "description"
}
