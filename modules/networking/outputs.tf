output "vpc_id" {
  value = aws_vpc.projects.id
}

output "subnet_id" {
  value = aws_subnet.frontend.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.projects.id
}

output "route_table_id" {
  value = aws_route_table.projects.id
}

output "frontend_subnet_id" {
  value = aws_subnet.frontend.id
}