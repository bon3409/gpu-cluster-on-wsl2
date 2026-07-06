output "rule_folder" {
  value = { for key, folder in grafana_folder.rule_folder : key => folder }
}
