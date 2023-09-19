variable "name" {}

variable "rg" {
  type = object({
    name     = string
    location = string
  })
}

variable "plan" {
  default = "Basic"
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

variable "exported_tables" {
  type    = set(string)
  default = []
}

variable "export_destination_id" {
  default = null
}

variable "subscription" {}