data "azurerm_client_config" "current" {}

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
  for_each                = var.exports
  name                    = "${azurerm_log_analytics_workspace.this.name}-data-export-${each.key}"
  resource_group_name     = var.rg.name
  workspace_resource_id   = azurerm_log_analytics_workspace.this.id
  destination_resource_id = each.value.destination_id
  table_names             = each.value.table_names
  enabled                 = true
}

resource "null_resource" "set_plan" {
  for_each = toset(flatten([for k, v in var.exports : [for t in v.table_names : "${k}-${t}"]]))
  triggers = {
    workspace = azurerm_log_analytics_workspace.this.id
    plan = var.export_plan
  }
  provisioner "local-exec" {
    command = "az monitor log-analytics workspace table update --subscription ${data.azurerm_client_config.current.subscription_id} --resource-group ${var.rg.name} --workspace-name ${azurerm_log_analytics_workspace.this.name} --name ${each.key} --plan ${var.export_plan}"
  }
}