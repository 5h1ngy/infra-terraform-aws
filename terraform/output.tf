output "frontend_public_ip" {
  description = "L'indirizzo IP pubblico della istanza frontend"
  value       = aws_instance.frontend.public_ip
}
