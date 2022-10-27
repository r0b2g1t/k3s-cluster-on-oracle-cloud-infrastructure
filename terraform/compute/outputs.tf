output "ad" {
  value = data.oci_identity_availability_domain.ad_2.name
}

output "cluster_token" {
  value = random_string.cluster_token.result
}

output "server_1_public_ip" {
  value = oci_core_instance.server.public_ip
}