variable "location" {
  type    = string
  default = "southindia"
}

variable "owner" {
  type = string

}

variable "unique_suffix" {
  type = string
}

variable "sql_admin_username" {
  type = string

}

variable "sql_admin_password" {
  type      = string
  sensitive = true

}