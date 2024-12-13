# modules/compute/main.tf
resource "aws_instance" "ec2demo" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  tags = {
    Name = "example-ec2-instance"
  }
}
