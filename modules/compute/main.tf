# modules/compute/main.tf
resource "aws_instance" "ec2demo" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  root_block_device {
    volume_size           = 8       # Dimensione del disco root in GiB
    volume_type           = "gp3"   # Tipo di volume (gp2, gp3, io1, etc.)
    delete_on_termination = true    # Elimina il volume quando l'istanza viene terminata
  }

  tags = {
    Name = "example-ec2-instance"
  }
}
