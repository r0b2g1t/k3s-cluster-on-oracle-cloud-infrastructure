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

variable "permit_http_nsg_id" {
  description = "NSG to permit HTTP(S)"
  type        = string
}

variable "permit_kubectl_nsg_id" {
  description = "NSG to permit Kubectl"
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

variable "init_server_image" {
  description = "The OCID for the aarch64 server image for the initial installation, must match the configured region"
  type        = string
  # Oracle-Linux-9.0-aarch64-2022.08.17-0
  # https://docs.oracle.com/en-us/iaas/images/oracle-linux-9x/
  default     = "ocid1.image.oc1.uk-london-1.aaaaaaaaf5niayyw6ldf5hec4hspbfarsh4hl7d6ylzwxv2aijdxajq6xfpa"
}

variable "init_agent_image" {
  description = "The OCID for the x86_64 agent image for the initial installation, must match the configured region"
  type        = string
  # Oracle-Linux-9.0-2022.08.17-0
  # https://docs.oracle.com/en-us/iaas/images/oracle-linux-9x/
  default     = "ocid1.image.oc1.uk-london-1.aaaaaaaavxuer26obsl2wedl56d5i5nok3uav7hdqy7tqq5ioqmtlt2xpqxq"
}

variable "server_0_user_data" {
  description = "Commands to be ran at boot for the bastion instance. Default installs Kali headless"
  type        = string
  default     = <<EOT
#!/bin/sh
sudo dnf install podman
EOT
}

variable "server_1_user_data" {
  description = "Commands to be ran at boot for the bastion instance. Default installs Kali headless"
  type        = string
  default     = <<EOT
#!/bin/sh
sudo dnf install podman
EOT
}

variable "agent_user_data" {
  description = "Commands to be ran at boot for the bastion instance. Default installs Kali headless"
  type        = string
  default     = <<EOT
#!/bin/sh
sudo dnf install podman
EOT
}

locals {
  server_instance_config = {
    shape_id = "VM.Standard.A1.Flex"
    ocpus    = 2
    ram      = 12
    source_id   = "${var.init_server_image}"
    source_type = "image"
    server_ip_0 = "10.0.0.10"
    server_ip_1 = "10.0.0.11"
    metadata = {
      "ssh_authorized_keys" = join("\n", var.ssh_authorized_keys)
    }
  }
  agent_instance_config = {
    shape_id = "VM.Standard.E2.1.Micro"
    ocpus    = 1
    ram      = 1
    source_id   = "${var.init_agent_image}"
    source_type = "image"
    agent_ips = [
      "10.0.0.20",
      "10.0.0.21"
    ]
    metadata = {
      "ssh_authorized_keys" = join("\n", var.ssh_authorized_keys)
    }
  }
}
