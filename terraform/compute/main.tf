resource "oci_core_instance" "server_1" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domain.ad_3.name
  display_name        = "k3s-server-1"
  shape               = local.server_instance_config.shape_id
  source_details {
    source_id   = local.server_instance_config.source_id
    source_type = local.server_instance_config.source_type
  }
  shape_config {
    memory_in_gbs = local.server_instance_config.ram
    ocpus         = local.server_instance_config.ocpus
  }
  create_vnic_details {
    subnet_id  = var.cluster_subnet_id
    private_ip = local.server_instance_config.server_ip_1
    nsg_ids    = [var.permit_ssh_nsg_id]
  }
  metadata = {
    "ssh_authorized_keys" = local.server_instance_config.metadata.ssh_authorized_keys
    "user_data" = base64encode(
      templatefile("${path.module}/templates/server_user_data.sh",
        {
          server_1_ip    = local.server_instance_config.server_ip_1,
          host_name      = "k3s-server-1",
          ssh_public_key = var.ssh_authorized_keys[0],
          token          = random_string.cluster_token.result,
          k3os_image     = local.server_instance_config.k3os_image
      })
    )
  }
}

resource "oci_core_instance" "server_2" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domain.ad_3.name
  display_name        = "k3s-server-2"
  shape               = local.server_instance_config.shape_id
  source_details {
    source_id   = local.server_instance_config.source_id
    source_type = local.server_instance_config.source_type
  }
  shape_config {
    memory_in_gbs = local.server_instance_config.ram
    ocpus         = local.server_instance_config.ocpus
  }
  create_vnic_details {
    subnet_id  = var.cluster_subnet_id
    private_ip = local.server_instance_config.server_ip_2
    nsg_ids    = [var.permit_ssh_nsg_id]
  }
  metadata = {
    "ssh_authorized_keys" = local.server_instance_config.metadata.ssh_authorized_keys
    "user_data" = base64encode(
      templatefile("${path.module}/templates/server_user_data.sh",
        {
          server_1_ip    = local.server_instance_config.server_ip_1,
          host_name      = "k3s-server-2",
          ssh_public_key = var.ssh_authorized_keys[0],
          token          = random_string.cluster_token.result,
          k3os_image     = local.server_instance_config.k3os_image
      })
    )
  }
  depends_on = [oci_core_instance.server_1]
}

resource "oci_core_instance" "worker" {
  count               = 2
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domain.ad_1.name
  display_name        = "k3s-worker-${count.index + 1}"
  shape               = local.worker_instance_config.shape_id
  source_details {
    source_id   = local.worker_instance_config.source_id
    source_type = local.worker_instance_config.source_type
  }
  shape_config {
    memory_in_gbs = local.worker_instance_config.ram
    ocpus         = local.worker_instance_config.ocpus
  }
  create_vnic_details {
    subnet_id = var.cluster_subnet_id
    nsg_ids   = [var.permit_ssh_nsg_id]
  }
  metadata = {
    "ssh_authorized_keys" = local.worker_instance_config.metadata.ssh_authorized_keys
    "user_data" = base64encode(
      templatefile("${path.module}/templates/worker_user_data.sh",
        {
          server_1_ip    = local.server_instance_config.server_ip_1,
          host_name      = "k3s-worker-${count.index + 1}",
          ssh_public_key = var.ssh_authorized_keys[0],
          token          = random_string.cluster_token.result,
          k3os_image     = local.worker_instance_config.k3os_image
    }))
  }
  depends_on = [oci_core_instance.server_2]
}
