resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "frontend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.frontend.id

  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  key_name = aws_key_pair.terraform_key.key_name

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # Creazione delle directory prima di tutto
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/nginx",
      "mkdir -p /home/ubuntu/ssl",
      "mkdir -p /home/ubuntu/services/frontend"
    ]
  }

  # Apps
  provisioner "file" {
    source      = "../data/services/frontend.zip"
    destination = "/home/ubuntu/frontend.zip"
  }

  # Docker compose & nginx
  provisioner "file" {
    source      = "../data/templates/docker-compose-frontend.yml"
    destination = "/home/ubuntu/docker-compose.yml"
  }
  provisioner "file" {
    source      = "../data/templates/nginx-frontend.conf"
    destination = "/home/ubuntu/nginx/nginx-frontend.conf"
  }

  # Certificati
  provisioner "file" {
    source      = "../data/ssl/nginx-selfsigned.crt"
    destination = "/home/ubuntu/ssl/nginx-selfsigned.crt"
  }

  provisioner "file" {
    source      = "../data/ssl/nginx-selfsigned.key"
    destination = "/home/ubuntu/ssl/nginx-selfsigned.key"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu" # Cambia in base all'AMI usata
    private_key = file(var.ssh_private_key_path)
    host        = self.public_ip
  }

  # Installazione di Docker, scompattamento e avvio Nginx containerizzato
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y docker.io unzip",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",

      # Installazione Docker Compose
      "sudo curl -L \"https://github.com/docker/compose/releases/download/v2.25.0/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",

      # Creazione directory per il frontend
      # "sudo mkdir -p /var/www/html",
      "sudo unzip -o /home/ubuntu/frontend.zip -d /home/ubuntu/services/frontend",
      # "sudo rm -rf /tmp/frontend.zip",

      # Creazione della directory dei certificati e spostamento file
      # "mkdir -p ~/certs",
      # "sudo mv /home/ubuntu/nginx-selfsigned.crt ~/certs/nginx-selfsigned.crt",
      # "sudo mv /home/ubuntu/nginx-selfsigned.key ~/certs/nginx-selfsigned.key",

      # Debug per verificare i file e le directory
      "ls -lpa /home/ubuntu/nginx",
      "ls -lpa /home/ubuntu/ssl",
      "ls -lpa /home/ubuntu/services/frontend",

      # "sudo chown -R www-data:www-data /home/ubuntu/services/frontend/fe-react-anime-watch",
      # "sudo chmod -R 755 /home/ubuntu/services/frontend/fe-react-anime-watch",
      # "sudo chown -R www-data:www-data /home/ubuntu/services/frontend/fe-react-anime-watch",
      # "sudo chmod -R 755 /home/ubuntu/services/frontend/fe-react-anime-watch",

      # Avvio del container Nginx
      "cd /home/ubuntu && sudo docker-compose --file /home/ubuntu/docker-compose.yml up --detach",
      # "sudo docker logs nginx-frontend"
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
