output "frontend_public_ip" {
  value       = service.frontend.public_ip
  description = "L'indirizzo IP pubblico dell'istanza EC2 creata"
}

output "backend_public_ip" {
  value       = service.backend.public_ip
  description = "L'indirizzo IP pubblico dell'istanza EC2 creata"
}
