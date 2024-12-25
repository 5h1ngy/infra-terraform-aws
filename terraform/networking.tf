resource "aws_vpc" "projects" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "projects-vpc"
  }
}

resource "aws_subnet" "frontend" {
  vpc_id                  = aws_vpc.projects.id
  cidr_block              = var.frontend_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "frontend-subnet"
  }
}

resource "aws_subnet" "backend" {
  vpc_id                  = aws_vpc.projects.id
  cidr_block              = var.backend_cidr_block
  map_public_ip_on_launch = true # Solitamente backend subnet è privata

  tags = {
    Name = "backend-subnet"
  }
}

resource "aws_internet_gateway" "projects" {
  vpc_id = aws_vpc.projects.id

  tags = {
    Name = "projects-igw"
  }
}

resource "aws_route_table" "projects" {
  vpc_id = aws_vpc.projects.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.projects.id
  }

  tags = {
    Name = "projects-route-table"
  }
}

# Associazione della route table con la subnet frontend
resource "aws_route_table_association" "frontend" {
  subnet_id      = aws_subnet.frontend.id
  route_table_id = aws_route_table.projects.id
}

# Associazione della route table con la subnet backend (se necessario)
resource "aws_route_table_association" "backend" {
  subnet_id      = aws_subnet.backend.id
  route_table_id = aws_route_table.projects.id
}