variable "compartment_id" {
  description = "OCI Compartment ID"
  type        = string
}

variable "tenancy_ocid" {
  description = "The tenancy OCID."
  type        = string
}

variable "cluster_subnet_id" {
  description = "Subnet for the bastion instance"
  type        = string
}

variable "permit_rules_nsg_id" {
  description = "NSG to permit SSH"
  type        = string
}

variable "ssh_authorized_keys" {
  description = "List of authorized SSH keys"
  type        = list(any)
}

variable k3s_version {
  description = "K3s version to be installed"
  default     = "v1.24.7+k3s1"
}

locals {
  server_instance_config = {
    shape_id    = "VM.Standard.A1.Flex"
    ocpus       = 2
    ram         = 12
    // Canonical-Ubuntu-20.04-aarch64
    // source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaaqkzlefkuyvhie3t3tmsaavfvvj3i6vcywkbftrnl3bmvtcjuw7a"
    // Canonical-Ubuntu-22.04-minimal-aarch64-2022.08.16-0
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaagmgvlgs6uexrh53be6qoe3bnhyavevpeyxrnd4xjmisc5km6hoia"
    source_type = "image"
    server_ip_1 = "10.0.0.20"
    metadata    = {
      "ssh_authorized_keys" = join("\n", var.ssh_authorized_keys)
    }
  }
  worker_instance_config = {
    shape_id    = "VM.Standard.A1.Flex"
    ocpus       = 1
    ram         = 6
    // Canonical-Ubuntu-20.04-aarch64
    // source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaaqkzlefkuyvhie3t3tmsaavfvvj3i6vcywkbftrnl3bmvtcjuw7a"
    // Canonical-Ubuntu-22.04-minimal-aarch64-2022.08.16-0
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaagmgvlgs6uexrh53be6qoe3bnhyavevpeyxrnd4xjmisc5km6hoia"
    source_type = "image"
    metadata    = {
      "ssh_authorized_keys" = join("\n", var.ssh_authorized_keys)
    }
  }
}

variable "email_address" {
  description = "Email address for CertManager"
  type        = string
}

variable "nlb_public_ip" {
  description = "NLB IP"
  type        = string
}
variable "nlb_private_ip" {
  description = "NLB IP"
  type        = string
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