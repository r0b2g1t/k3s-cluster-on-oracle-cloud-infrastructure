output "nlb_public_ip" {
  description = "Public IP of NLB"
  value = [for ip in oci_network_load_balancer_network_load_balancer.test_network_load_balancer.ip_addresses : ip if ip.is_public == true][0].ip_address
  depends_on  = [oci_network_load_balancer_network_load_balancer.test_network_load_balancer]
}

output "nlb_private_ip" {
  description = "Private IP of NLB"
  value = [for ip in oci_network_load_balancer_network_load_balancer.test_network_load_balancer.ip_addresses : ip if ip.is_public == false][0].ip_address
  depends_on  = [oci_network_load_balancer_network_load_balancer.test_network_load_balancer]
}