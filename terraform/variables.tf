variable "compartment_id" {
  description = "OCI Compartment ID"
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the key to use for signing"
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key to use for signing"
  type        = string
}

variable "region" {
  description = "The region to connect to. Default: eu-frankfurt-1"
  type        = string
  default     = "eu-frankfurt-1"
}

variable "tenancy_ocid" {
  description = "The tenancy OCID."
  type        = string
}

variable "user_ocid" {
  description = "The user OCID."
  type        = string
}

variable "ssh_authorized_keys" {
  description = "List of authorized SSH keys"
  type        = list(any)
}

variable "email_address" {
  description = "Email address for CertManager"
  type = string
}
variable "custom_domain" {
  description = "custom domain for access"
  type        = string
}

variable "oci_bucket" {
  description = "Name of the Object Store bucket for K3s backup"
  type        = string
}

variable "oci_bucket_folder" {
  description = "Name of the Object Store bucket for K3s backup"
  type        = string
}

variable "oci_bucket_ak" {
  description = "OCI Access Key for S3"
  type        = string
}

variable "oci_bucket_sk" {
  description = "OCI Secret Key for S3"
  type        = string
}