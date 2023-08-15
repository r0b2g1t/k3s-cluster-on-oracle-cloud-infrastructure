resource "oci_core_instance" "server_0" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domain.ad_1.name
  display_name        = "k3s-server-0"
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
    private_ip = local.server_instance_config.server_ip_0
    nsg_ids    = [
      var.permit_http_nsg_id,
      var.permit_kubectl_nsg_id,
      var.permit_ssh_nsg_id
    ]
  }
  metadata = {
    "ssh_authorized_keys" = local.server_instance_config.metadata.ssh_authorized_keys
    "user_data" = base64encode(
      templatefile("${path.module}/templates/fcos.bu",
        {
          host_name      = "k3s-server-0",
          ip_address     = local.agent_instance_config.agent_ips[0],
          rollout_time     = "13:00",
          rollout_wariness = 0.7,
          ssh_public_key = var.ssh_authorized_keys[0]
        }
      )
    )
  }
}

resource "oci_core_instance" "server_1" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domain.ad_2.name
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
    nsg_ids    = [
      var.permit_http_nsg_id,
      var.permit_kubectl_nsg_id,
      var.permit_ssh_nsg_id
    ]
  }
  metadata = {
    "ssh_authorized_keys" = local.server_instance_config.metadata.ssh_authorized_keys
    "user_data" = base64encode(
      templatefile("${path.module}/templates/fcos.bu",
        {
          host_name        = "k3s-server-1",
          ip_address       = local.agent_instance_config.agent_ips[1],
          rollout_time     = "19:00",
          rollout_wariness = 0.9,
          ssh_public_key   = var.ssh_authorized_keys[0]
        }
      )
    )
  }
  depends_on = [oci_core_instance.server_0]
}

resource "oci_core_instance" "agent" {
  count               = 2
  compartment_id      = var.compartment_id
  # Instances using the VM.Standard.E2.1.Micro shape must go in the
  # DhmS:UK-LONDON-1-AD-2 availability domain.
  availability_domain = data.oci_identity_availability_domain.ad_2.name
  display_name        = "k3s-agent-${count.index}"
  shape               = local.agent_instance_config.shape_id
  source_details {
    source_id   = local.agent_instance_config.source_id
    source_type = local.agent_instance_config.source_type
  }
  shape_config {
    memory_in_gbs = local.agent_instance_config.ram
    ocpus         = local.agent_instance_config.ocpus
  }
  create_vnic_details {
    subnet_id = var.cluster_subnet_id
    private_ip = local.agent_instance_config.agent_ips[count.index]
    nsg_ids    = [
      var.permit_http_nsg_id,
      var.permit_ssh_nsg_id
    ]
  }
  metadata = {
    "ssh_authorized_keys" = local.agent_instance_config.metadata.ssh_authorized_keys
    "user_data" = base64encode(
      templatefile("${path.module}/templates/fcos.bu",
        {
          host_name        = "k3s-agent-${count.index}",
          ip_address       = local.agent_instance_config.agent_ips[count.index],
          rollout_time     = "0${1 + 2 * count.index}:00"
          rollout_wariness = 0.3 + 0.1 * count.index,
          ssh_public_key   = var.ssh_authorized_keys[0]
        }
      )
    )
  }
  depends_on = [oci_core_instance.server_1]
}
