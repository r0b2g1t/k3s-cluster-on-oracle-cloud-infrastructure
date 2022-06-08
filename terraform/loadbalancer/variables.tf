variable "compartment_id" {
  description = "OCI Compartment ID"
  type        = string
}

variable "tenancy_ocid" {
  description = "The tenancy OCID."
  type        = string
}


variable "permit_rules_nsg_id" {
  description = "NSG to permit SSH HTTP HTTPS K8S_API"
  type        = string
}


variable "cluster_subnet_id" {
  description = "Subnet for the bastion instance"
  type        = string
}

variable "network_load_balancer_display_name" {
  description = ""
  type        = string
  default     = "test_nlb"
}

variable "network_load_balancer_nlb_ip_version" {
  description = "NLB IP Version"
  type        = string
  default     = "IPV4"
}


variable "network_load_balancer_is_private" {
  description = "NLB access"
  type        = string
  default     = false
}