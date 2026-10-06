variable "storage_account_name" {
  description = "Globally unique Azure Storage account name"
  type        = string

  default = "iacsecurityprod12345"
}
variable "management_cidr" {
  description = "Trusted management CIDR permitted to use SSH"
  type        = string

  # Example documentation IP only.
  # Replace with an approved management address.
  default = "203.0.113.10/32"
}