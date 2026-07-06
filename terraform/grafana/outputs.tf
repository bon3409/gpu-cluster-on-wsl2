output "rule_folder" {
  value = { for key, folder in grafana_folder.rule_folder : key => folder }
}

# output "alert_uids" {
#   value = [for k, v in grafana_rule_group.dcgm_alerts : v.rule[0].uid]
# }