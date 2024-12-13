# modules/networking/outputs.tf
output "vpc_id" {
  value = aws_vpc.example.id
}

output "subnet_id" {
  value = aws_subnet.example.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.example.id
}

output "route_table_id" {
  value = aws_route_table.example.id
}
