output "server_1_public_ip" {
  description = "Public IP of the ControlPlane node"
  value       = module.compute.server_1_public_ip
}

output "nlb_public_ip" {
  description = "LoadBalancer Public IP for Ingress and K8s API"
  value       = module.loadbalancer.nlb_public_ip
}