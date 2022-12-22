resource "oci_core_instance" "server_0" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domain.ad_3.name
  display_name        = "k3s_server_0"
  shape               = local.ampere_instance_config.shape_id
  source_details {
    source_id   = local.ampere_instance_config.source_id
    source_type = local.ampere_instance_config.source_type
  }
  shape_config {
    memory_in_gbs = local.ampere_instance_config.ram
    ocpus         = local.ampere_instance_config.ocpus
  }
  create_vnic_details {
    subnet_id  = var.cluster_subnet_id
    private_ip = cidrhost(var.cidr_blocks[0],10)
    nsg_ids    = [var.permit_ssh_nsg_id]
  }
  metadata = {
    "ssh_authorized_keys" = local.ampere_instance_config.metadata.ssh_authorized_keys
    "user_data" = base64encode(
      templatefile("${path.module}/templates/server.sh",
        {
          server_0_ip    = oci_core_instance.server_0.private_ip,
          token          = random_string.cluster_token.result
      })
    )
  }
}

resource "oci_core_instance" "server_1" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domain.ad_3.name
  display_name        = "k3s_server_1"
  shape               = local.ampere_instance_config.shape_id
  source_details {
    source_id   = local.ampere_instance_config.source_id
    source_type = local.ampere_instance_config.source_type
  }
  shape_config {
    memory_in_gbs = local.ampere_instance_config.ram
    ocpus         = local.ampere_instance_config.ocpus
  }
  create_vnic_details {
    subnet_id  = var.cluster_subnet_id
    private_ip = cidrhost(var.cidr_blocks[0],11)
    nsg_ids    = [var.permit_ssh_nsg_id]
  }
  metadata = {
    "ssh_authorized_keys" = local.ampere_instance_config.metadata.ssh_authorized_keys
    "user_data" = base64encode(
      templatefile("${path.module}/templates/server.sh",
        {
          server_0_ip    = oci_core_instance.server_0.private_ip,
          token          = random_string.cluster_token.result
      })
    )
  }
  depends_on = [oci_core_instance.server_0]
}

resource "oci_core_instance" "server_2+" {
  count               = 2
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domain.ad_1.name
  display_name        = "k3s_server_${count.index + 2}"
  shape               = local.micro_instance_config.shape_id
  source_details {
    source_id   = local.micro_instance_config.source_id
    source_type = local.micro_instance_config.source_type
  }
  shape_config {
    memory_in_gbs = local.micro_instance_config.ram
    ocpus         = local.micro_instance_config.ocpus
  }
  create_vnic_details {
    subnet_id = var.cluster_subnet_id
    private_ip = cidrhost(var.cidr_blocks[0],count.index + 20)
    nsg_ids   = [var.permit_ssh_nsg_id]
  }
  metadata = {
    "ssh_authorized_keys" = local.micro_instance_config.metadata.ssh_authorized_keys
    "user_data" = base64encode(
      templatefile("${path.module}/templates/server.sh",
        {
          server_0_ip    = local.ampere_instance_config.server_ip_0,
          token          = random_string.cluster_token.result,
    }))
  }
  depends_on = [oci_core_instance.server_1]
}