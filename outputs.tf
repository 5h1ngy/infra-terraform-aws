# outputs.tf
output "instance_public_ip" {
  value       = module.compute.instance_public_ip
  description = "L'indirizzo IP pubblico dell'istanza EC2 creata"
}
