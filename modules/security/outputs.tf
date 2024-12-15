output "frontend_sg_id" {
  value       = aws_security_group.frontend_sg.id
  description = "The ID of the frontend security group"
}
