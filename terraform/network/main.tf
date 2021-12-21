resource "oci_core_vcn" "cluster_network" {
  compartment_id = var.compartment_id

  cidr_blocks = [
    "10.0.0.0/24"
  ]
  display_name = "cluster-vcn"
  dns_label    = "internal"
}

resource "oci_core_default_security_list" "default_list" {
  manage_default_resource_id = oci_core_vcn.cluster_network.default_security_list_id

  display_name = "Outbound only (default)"

  egress_security_rules {
    protocol    = "all" // TCP
    description = "Allow outbound"
    destination = "0.0.0.0/0"
  }
  ingress_security_rules {
    protocol    = "all"
    description = "Allow inter-subnet traffic"
    source      = "10.0.0.0/24"
  }
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.cluster_network.id
  enabled        = true
}

resource "oci_core_default_route_table" "internet_route_table" {
  compartment_id             = var.compartment_id
  manage_default_resource_id = oci_core_vcn.cluster_network.default_route_table_id

  route_rules {
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "cluster_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.cluster_network.id
  cidr_block        = oci_core_vcn.cluster_network.cidr_blocks[0]
  display_name      = "cluster subnet"
  security_list_ids = [oci_core_vcn.cluster_network.default_security_list_id]
}

resource "oci_core_network_security_group" "permit_ssh" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.cluster_network.id
  display_name   = "Permit SSH"
}

resource "oci_core_network_security_group_security_rule" "permit_ssh" {
  network_security_group_id = oci_core_network_security_group.permit_ssh.id
  protocol                  = "6" // TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
  direction = "INGRESS"
}
