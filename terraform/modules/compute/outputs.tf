output "frontend_public_ip" {
  value       = aws_instance.frontend.public_ip
  description = "L'indirizzo IP pubblico dell'istanza EC2 creata"
}

# output "backend_public_ip" {
#   value       = aws_instance.backend.public_ip
#   description = "L'indirizzo IP pubblico dell'istanza EC2 creata"
# }
