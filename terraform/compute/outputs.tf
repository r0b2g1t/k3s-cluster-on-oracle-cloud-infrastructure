output "ad" {
  value = data.oci_identity_availability_domain.ad.name
}

output "cluster_token" {
  value = random_string.cluster_token.result
}
