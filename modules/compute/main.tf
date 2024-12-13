# modules/compute/main.tf
resource "aws_instance" "ec2demo" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  root_block_device {
    volume_size           = 8     # Dimensione del disco root in GiB
    volume_type           = "gp3" # Tipo di volume (gp2, gp3, io1, etc.)
    delete_on_termination = true  # Elimina il volume quando l'istanza viene terminata
  }

  tags = {
    Name = "example-ec2-instance"
  }
}

/*
  Extension prototype
*/
resource "aws_instance" "frontend" {
  ami           = "ami-075449515af5df0d1"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.frontend.id

  provisioner "file" {
    source      = "./frontend/dist"
    destination = "/var/www/html"
  }

  provisioner "file" {
    source      = "./nginx-frontend.conf"
    destination = "/etc/nginx/sites-enabled/frontend.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo mv /etc/nginx/sites-enabled/frontend.conf /etc/nginx/sites-enabled/default",
      "sudo systemctl restart nginx"
    ]
  }

  tags = {
    Name = "frontend-instance"
  }
}

resource "aws_instance" "backend" {
  ami           = "ami-075449515af5df0d1"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.backend.id

  provisioner "file" {
    source      = "./backend/projects"
    destination = "/var/www/api"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash",
      "export NVM_DIR=\"$HOME/.nvm\" && [ -s \"$NVM_DIR/nvm.sh\" ] && \\\"$NVM_DIR/nvm.sh\\\"",
      "nvm install 16",
      "cd /var/www/api && npm install --production",
      "pm2 start all"
    ]
  }

  tags = {
    Name = "backend-instance"
  }
}
