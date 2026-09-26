locals {
  manifests_file_hash = sha256(join("", [
    for f in sort(fileset("${path.module}/chart", "**")) :
    filesha256("${path.module}/chart/${f}")
  ]))
}

# 使用 helm_release Resource 部署本地 Chart
resource "helm_release" "triton_server" {
  name             = "triton-server"
  chart            = "./chart" # 指向本地 Chart 目錄
  namespace        = "triton"
  create_namespace = true

  # 透過 set 動態注入或覆蓋 values.yaml 中的變數
  set = [
    {
      name  = "modelRepository.hostPath"
      value = var.model_host_path
    },
    { name  = "resources.limits.nvidia\\.com/gpu"
      value = "1"
    }
  ]

  values = [
    jsonencode({
      manifests_file_hash = local.manifests_file_hash
    })
  ]
}