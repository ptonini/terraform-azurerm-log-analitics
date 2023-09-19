variable "name" {}

variable "rg" {
  type = object({
    name     = string
    location = string
  })
}

variable "retention_in_days" {
  default = 7
}

variable "daily_quota_gb" {
  default = 0.5
}

variable "sku" {
  default = "Free"
}

variable "exports" {
  type = map(object({
    destination_id = string
    table_names = set(string)
  }))
  default = {}
}

variable "export_plan" {
  default = "Basic"
}