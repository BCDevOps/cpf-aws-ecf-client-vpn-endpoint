variable "domain_name" {
  description = "Domain Name to associate with ACM common name"
  type        = string
  default     = "opensearchsiem"
}

variable "name" {
  description = "Name to associate with various resources"
  type        = string
  default     = "siem"
}

variable "keycloak_realm_id" {
  description = "Keycloak realm id"
  type        = string
}

variable "logs_retention" {
  description = "CloudWatch logs retention period"
  type        = string
  default     = 365
}