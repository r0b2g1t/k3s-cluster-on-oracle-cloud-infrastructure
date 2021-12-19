output "vcn" {
  description = "Created VCN"
  value       = oci_core_vcn.cluster_network
}

output "cluster_subnet" {
  description = "Subnet of the k3s cluser"
  value       = oci_core_subnet.cluster_subnet
  depends_on  = [oci_core_subnet.cluster_subnet]
}

output "permit_ssh" {
  description = "NSG to permit ssh"
  value       = oci_core_network_security_group.permit_ssh
}

output "ad" {
  value = data.oci_identity_availability_domain.ad.name
}
