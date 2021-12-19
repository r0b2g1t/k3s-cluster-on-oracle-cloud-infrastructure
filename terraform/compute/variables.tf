variable "compartment_id" {
  description = "OCI Compartment ID"
  type        = string
}

variable "cluster_token" {
  description = "OCI Cluster Token"
  type        = string
}
  
}


variable "cluster_subnet_id" {
  description = "Subnet for the bastion instance"
  type        = string
}

variable "permit_ssh_nsg_id" {
  description = "NSG to permit SSH"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for subnets"
  type        = string
  default     = "xdil:US-SANJOSE-1-AD-1"
}

variable "ssh_authorized_keys" {
  description = "List of authorized SSH keys"
  type        = list(any)
  default = [
    "",
  ]
}

variable "master_1_user_data" {
  description = "Commands to be ran at boot for the bastion instance. Default installs Kali headless"
  type        = string
  default     = <<EOT
#!/bin/sh
sudo apt-get update
EOT
}
variable "master_2_user_data" {
  description = "Commands to be ran at boot for the bastion instance. Default installs Kali headless"
  type        = string
  default     = <<EOT
#!/bin/sh
sudo apt-get update
EOT
}
variable "worker_user_data" {
  description = "Commands to be ran at boot for the bastion instance. Default installs Kali headless"
  type        = string
  default     = <<EOT
#!/bin/sh
sudo apt-get update
EOT
}

locals {
  instance_config = {
    server = {
        shape_id = "VM.Standard.A1.Flex"
        ocpus    = 2
        ram      = 12
    }
    worker = {
        shape_id = "VM.Standard.E2.1.Micro"
    }
    source_details = {
      // Canonical-Ubuntu-20.04-2021.10.15-0
      source_id   = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaugtulb77ufxo7io3zw2hj2cy34oerrfjweg6hlvxaffze754mm7a"
      source_type = "image"
    }
    server_ip_1   = 10.0.0.11
    server_ip_2   = 10.0.0.12
    worker_ip_1   = 10.0.0.21
    worker_ip_2   = 10.0.0.22
    metadata = {
      "ssh_authorized_keys" = join("\n", var.ssh_authorized_keys)
    }
    availability_domain = var.availability_domain
    server_1_userdata = templatefile("${path.module}/server_user_data.tftpl",
        {
            server_ip   = local.server_ip_1,
            host_name = oci_core_instance.server_1.display_name,
            ssh_public_key = var.ssh_authorized_keys[0],
            token = var.cluster_token
        })
    server_2_userdata = templatefile("${path.module}/server_user_data.tftpl",
        {
            server_ip   = local.server_ip_2,
            host_name = oci_core_instance.server_2.display_name,
            ssh_public_key = var.ssh_authorized_keys[0],
            token = var.cluster_token
        })    
  }
}
