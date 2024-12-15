resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "frontend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.frontend_subnet_id

  vpc_security_group_ids = [var.frontend_sg_id]

  # Utilizza user_data per configurare la chiave pubblica
  # Associa la chiave SSH gestita da AWS
  key_name = aws_key_pair.terraform_key.key_name

  # Configurazione del disco root
  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # Copia dei file frontend specifici al progetto

  provisioner "file" {
    source      = "./services/frontend.zip"
    destination = "/tmp/frontend.zip"
  }

  # Copia il file Nginx manuale sulla macchina
  provisioner "file" {
    source      = "./templates/nginx-frontend.conf"
    destination = "/tmp/nginx.conf"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu" # Cambia in base all'AMI usata
    private_key = file(var.ssh_private_key_path)
    host        = self.public_ip
  }

  # Configurazione remota per Nginx
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx unzip -y",
      "sudo unzip -o /tmp/frontend.zip -d /var/www/html/",
      "sudo rm -rfdv /tmp/frontend.zip",
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo rm -rfdv /tmp/nginx.conf",
      "sudo chown -R www-data:www-data /var/www/html",
      "sudo chmod -R 755 /var/www/html",
      "for d in /var/www/html/*; do sudo chmod -R www-data:www-data $d; done",
      "for d in /var/www/html/*; do sudo chmod -R 755 $d; done",
      "sudo nginx -t",
      "sudo systemctl restart nginx"
    ]
  }

  tags = {
    Name = "services-frontend"
  }
}

# resource "service" "backend" {
#   ami           = var.ami_id
#   instance_type = var.instance_type
#   subnet_id     = var.backend_cidr_block

#   # Configurazione del disco root
#   root_block_device {
#     volume_size           = 8
#     volume_type           = "gp3"
#     delete_on_termination = true
#   }

#   # Copia i progetti Node.js sulla macchina EC2
#   provisioner "file" {
#     source      = "./services/backend.zip"
#     destination = "/tmp/backend.zip"
#   }

#   # Copia il file Nginx manuale sulla macchina
#   provisioner "file" {
#     source      = "./templates/nginx-backend.conf"
#     destination = "/etc/nginx/nginx.conf"
#   }

#   connection {
#     type        = "ssh"
#     user        = "ubuntu" # Cambia in base all'AMI usata
#     private_key = file(var.ssh_private_key_path)
#     host        = self.public_ip
#   }

#   # Configura e avvia i servizi
#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt update -y",
#       "sudo apt install nginx unzip -y",
#       "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash",
#       "export NVM_DIR=\"$HOME/.nvm\" && [ -s \"$NVM_DIR/nvm.sh\" ] && \\\"$NVM_DIR/nvm.sh\\\"",
#       "nvm install 20.18.0",
#       "sudo unzip -o /tmp/backend.zip -d /var/www/api/",
#       "sudo rm -rfdv /tmp/backend.zip",
#       "for d in /var/www/api/*; do (cd $d && npm install --production && pm2 start index.js --name $(basename $d)); done",
#       "sudo systemctl restart nginx"
#     ]
#   }

#   tags = {
#     Name = "services-backend"
#   }
# }
