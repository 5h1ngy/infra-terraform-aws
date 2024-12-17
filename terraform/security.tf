resource "aws_security_group" "frontend_sg" {
  name_prefix = "frontend-sg-"
  description = "Security Group for the frontend instance"
  vpc_id      = aws_vpc.projects.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consenti SSH da ovunque
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consenti HTTP da ovunque
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consenti HTTPS da ovunque
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Consenti traffico in uscita
  }

  tags = {
    Name = "frontend-sg"
  }
}
