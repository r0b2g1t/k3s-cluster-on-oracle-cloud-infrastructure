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

variable "permit_ssh_nsg_id" {
  description = "NSG to permit SSH"
  type        = string
}

variable "ssh_authorized_keys" {
  description = "List of authorized SSH keys"
  type        = list(any)
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
  server_instance_config = {
    shape_id = "VM.Standard.A1.Flex"
    ocpus    = 2
    ram      = 12
    // Canonical-Ubuntu-20.04-aarch64-2021.12.01-0
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaerzsdjk2ahjgfgf2zxtxtnpl3n3ew6qse2g2lxnnumxui7hsmsja"
    source_type = "image"
    server_ip_1 = "10.0.0.11"
    server_ip_2 = "10.0.0.12"
    // release: v0.21.5-k3s2r1
    k3os_image = "https://github.com/rancher/k3os/releases/download/v0.21.5-k3s2r1/k3os-arm64.iso"
    metadata = {
      "ssh_authorized_keys" = join("\n", var.ssh_authorized_keys)
    }
  }
  worker_instance_config = {
    shape_id = "VM.Standard.E2.1.Micro"
    ocpus    = 1
    ram      = 1
    // Canonical-Ubuntu-20.04-aarch64-2021.12.01-0
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaadlurdwl77zh7l5dlngngxjormr3xvqvapiaiv6gbuffo6dzfu6la"
    source_type = "image"
    worker_ip_0 = "10.0.0.21"
    worker_ip_1 = "10.0.0.22"
    // release: v0.21.5-k3s2r1
    k3os_image = "https://github.com/rancher/k3os/releases/download/v0.21.5-k3s2r1/k3os-amd64.iso"
    metadata = {
      "ssh_authorized_keys" = join("\n", var.ssh_authorized_keys)
    }
  }
}
