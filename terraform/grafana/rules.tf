resource "grafana_folder" "rule_folder" {
  for_each = local.rule_group
  title    = each.value.folder
}

resource "grafana_rule_group" "rules" {
  for_each = local.rule_group

  name             = each.value.name
  folder_uid       = grafana_folder.rule_folder[each.key].uid
  interval_seconds = 60

  dynamic "rule" {
    for_each = each.value.rules

    content {
      name      = rule.value.name
      condition = rule.value.condition

      dynamic "data" {
        for_each = rule.value.data

        content {
          ref_id         = data.value.ref_id
          datasource_uid = data.value.datasource_uid
          query_type     = data.value.query_type

          relative_time_range {
            from = data.value.relative_time_range.from
            to   = data.value.relative_time_range.to
          }

          model = jsonencode(data.value.model)
        }
      }
    }
  }

  depends_on = [grafana_contact_point.contact_points, grafana_folder.rule_folder]
}