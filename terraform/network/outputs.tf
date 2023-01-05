output "vcn" {
  description = "Created VCN"
  value       = oci_core_vcn.cluster_network
}

output "cluster_subnet" {
  description = "Subnet of the k3s cluser"
  value       = oci_core_subnet.cluster_subnet
  depends_on  = [oci_core_subnet.cluster_subnet]
}

output "permit_http" {
  description = "NSG to permit HTTP(S)"
  value       = oci_core_network_security_group.permit_http
}

output "permit_kubectl" {
  description = "NSG to permit Kubectl"
  value       = oci_core_network_security_group.permit_kubectl
}

output "permit_ssh" {
  description = "NSG to permit SSH"
  value       = oci_core_network_security_group.permit_ssh
}

output "ad" {
  value = data.oci_identity_availability_domain.ad.name
}
