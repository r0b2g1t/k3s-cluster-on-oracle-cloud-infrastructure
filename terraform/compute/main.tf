resource "oci_core_instance" "server_1" {
  compartment_id      = var.compartment_id
  availability_domain = local.instance_config.availability_domain
  display_name        = "k3s-server-1"
  shape               = local.instance_config.shape_id
  source_details {
    source_id   = local.instance_config.source_details.source_id
    source_type = local.instance_config.source_details.source_type
  }
  shape_config {
    memory_in_gbs = local.instance_config.server.ram
    ocpus         = local.instance_config.server.ocpus
  }
  create_vnic_details {
    subnet_id  = var.cluster_subnet_id
    private_ip = local.instance_config.server_ip_1
    nsg_ids    = [var.permit_ssh_nsg_id]
  }
  metadata = {
    "ssh_authorized_keys" = local.instance_config.metadata.ssh_authorized_keys
    "user_data"           = base64encode(
      templatefile("${path.module}/server_user_data.sh",
        {
            server_ip      = local.server_ip_1,
            host_name      = "k3s-server-1",
            ssh_public_key = var.ssh_authorized_keys[0],
            token          = var.cluster_token
        })
    )
  }
}

resource "oci_core_instance" "server_2" {
  compartment_id      = var.compartment_id
  availability_domain = local.instance_config.availability_domain
  display_name        = "k3s-server-2"
  shape               = local.instance_config.shape_id
  source_details {
    source_id   = local.instance_config.source_details.source_id
    source_type = local.instance_config.source_details.source_type
  }
  shape_config {
    memory_in_gbs = local.instance_config.server.ram
    ocpus         = local.instance_config.server.ocpus
  }
  create_vnic_details {
    subnet_id  = var.cluster_subnet_id
    private_ip = local.instance_config.server_ip_2
    nsg_ids    = [var.permit_ssh_nsg_id]
  }
  metadata = {
    "ssh_authorized_keys" = local.instance_config.metadata.ssh_authorized_keys
    "user_data"           = base64encode(
      templatefile("${path.module}/server_user_data.sh",
        {
            server_1_ip    = local.server_ip_1,
            server_2_ip    = local.server_ip_2,
            host_name      = "k3s-server-2",
            ssh_public_key = var.ssh_authorized_keys[0],
            token          = var.cluster_token
        })
    )
  }
  depends_on = [oci_core_instance.server_1]
}

resource "oci_core_instance" "worker" {
  count               = 2
  compartment_id      = var.compartment_id
  availability_domain = local.instance_config.availability_domain
  display_name        = "k3s-worker-${count.index}"
  shape               = local.instance_config.shape_id
  source_details {
    source_id   = local.instance_config.source_details.source_id
    source_type = local.instance_config.source_details.source_type
  }
  shape_config {
    memory_in_gbs = local.instance_config.server.ram
    ocpus         = local.instance_config.server.ocpus
  }
  create_vnic_details {
    subnet_id  = var.cluster_subnet_id
    private_ip = local.instance_config.server_ip_${count.index}
    nsg_ids    = [var.permit_ssh_nsg_id]
  }
  metadata = {
    "ssh_authorized_keys" = local.instance_config.metadata.ssh_authorized_keys
    "user_data"           = base64encode(
      templatefile("${path.module}/worker_user_data.sh",
        {
            server_1_ip    = local.server_ip_1,
            worker_ip      = "local.worker_ip_${count.index}",
            host_name      = "k3s-worker-${count.index}",
            ssh_public_key = var.ssh_authorized_keys[0],
            token          = var.cluster_token
        }))
  }
  depends_on = [oci_core_instance.server_1]
}
