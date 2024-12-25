output "frontend_public_ip" {
  description = "L'indirizzo IP pubblico della istanza frontend"
  value       = aws_instance.frontend.public_ip
}

output "backend_public_ip" {
  description = "L'indirizzo IP pubblico della istanza backend"
  value       = aws_instance.backend.public_ip
}
