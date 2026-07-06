resource "grafana_contact_point" "contact_points" {
  for_each = local.contact_points
  name     = each.value.name

  email {
    addresses               = each.value.email
    message                 = "{{ len .Alerts.Firing }} firing."
    subject                 = "{{ template \"default.title\" .}}"
    single_email            = true
    disable_resolve_message = false
  }
}

resource "grafana_notification_policy" "default" {
  contact_point = grafana_contact_point.contact_points["default"].name
  group_by      = ["..."]

  policy {
    matcher {
      label = "severity"
      match = "="
      value = "warning"
    }

    contact_point = grafana_contact_point.contact_points["warning"].name
  }

  policy {
    matcher {
      label = "severity"
      match = "="
      value = "critical"
    }

    contact_point = grafana_contact_point.contact_points["critical"].name
  }
}