resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  resource_group_name = var.rg.name
  location            = var.rg.location
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb
  sku                 = var.sku

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_log_analytics_data_export_rule" "this" {
  count                   = var.exported_tables == [] ? 0 : 1
  name                    = "${azurerm_log_analytics_workspace.this.name}-data-export"
  resource_group_name     = var.rg.name
  workspace_resource_id   = azurerm_log_analytics_workspace.this.id
  destination_resource_id = var.export_destination_id
  table_names             = var.exported_tables
  enabled                 = true
}

resource "null_resource" "set_plan" {
  triggers = {
    workspace = azurerm_log_analytics_workspace.this.id
    plan = var.plan
  }
  for_each = var.exported_tables
  provisioner "local-exec" {
    command = "az monitor log-analytics workspace table update --subscription ${var.subscription} --resource-group ${var.rg.name} --workspace-name ${azurerm_log_analytics_workspace.this.name} --name ${each.key} --plan ${var.plan}"
  }
}