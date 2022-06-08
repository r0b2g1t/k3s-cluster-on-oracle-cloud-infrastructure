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
  default     = "v1.21.12+k3s1"
}

locals {
  server_instance_config = {
    shape_id = "VM.Standard.A1.Flex"
    ocpus    = 2
    ram      = 12
    // Canonical-Ubuntu-20.04-aarch64
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaaqkzlefkuyvhie3t3tmsaavfvvj3i6vcywkbftrnl3bmvtcjuw7a"
    source_type = "image"
    server_ip_1 = "10.0.0.20"
    metadata = {
      "ssh_authorized_keys" = join("\n", var.ssh_authorized_keys)
    }
  }
  worker_instance_config = {
    shape_id = "VM.Standard.E2.1.Micro"
    ocpus    = 1
    ram      = 1
    // Canonical-Ubuntu-20.04-amd64
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaagplxd7wojwcfx4dhtbrujrfni2u5yvrkpfvatnwneohdloeyihva"
    source_type = "image"
    metadata = {
      "ssh_authorized_keys" = join("\n", var.ssh_authorized_keys)
    }
  }
  worker_instance_config2 = {
    shape_id = "VM.Standard.A1.Flex"
    ocpus    = 2
    ram      = 12
    // Canonical-Ubuntu-20.04-aarch64
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaaqkzlefkuyvhie3t3tmsaavfvvj3i6vcywkbftrnl3bmvtcjuw7a"
    source_type = "image"
    metadata = {
      "ssh_authorized_keys" = join("\n", var.ssh_authorized_keys)
    }
  }
}

variable "email_address" {
  description = "Email address for CertManager"
  type = string
}

variable "nlb_public_ip" {
  description = "NLB IP"
  type        = string
}
variable "nlb_private_ip" {
  description = "NLB IP"
  type        = string
}
