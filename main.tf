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

resource "null_resource" "set_plan" {
  for_each = var.exported_tables
  triggers = {
    workspace = azurerm_log_analytics_workspace.this.id
    plan = var.plan
  }
  provisioner "local-exec" {
    command = "az monitor log-analytics workspace table update --subscription ${var.subscription} --resource-group ${var.rg.name} --workspace-name ${azurerm_log_analytics_workspace.this.name} --name ${each.key} --plan ${var.plan}"
  }
}