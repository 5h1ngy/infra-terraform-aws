# modules/compute/outputs.tf
output "instance_public_ip" {
  value       = aws_instance.ec2demo.public_ip
  description = "L'indirizzo IP pubblico dell'istanza EC2 creata"
}
