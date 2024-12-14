resource "service" "frontend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_frontend_id

  # Configurazione del disco root
  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # Copia dei file frontend specifici al progetto
  
  provisioner "file" {
    source      = "./services/frontend.tar"
    destination = "/tmp/frontend.tar"
  }

  # Copia il file Nginx manuale sulla macchina
  provisioner "file" {
    source      = "./templates/nginx-frontend.conf"
    destination = "/etc/nginx/nginx.conf"
  }

  # Configurazione remota per Nginx
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx unzip -y",
      "sudo unzip -o /tmp/frontend.tar -d /var/www/html/",
      "sudo rm -rfdv /tmp/frontend.tar",
      "for d in /var/www/html/*; do sudo chmod -R 755 $d; done",
      "sudo systemctl restart nginx"
    ]
  }

  tags = {
    Name = "services-frontend"
  }
}

resource "service" "backend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_backend_id

  # Configurazione del disco root
  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # Copia i progetti Node.js sulla macchina EC2
  provisioner "file" {
    source      = "./services/backend.tar"
    destination = "/tmp/backend.tar"
  }

  # Copia il file Nginx manuale sulla macchina
  provisioner "file" {
    source      = "./templates/nginx-backend.conf"
    destination = "/etc/nginx/nginx.conf"
  }

  # Configura e avvia i servizi
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx unzip -y",
      "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash",
      "export NVM_DIR=\"$HOME/.nvm\" && [ -s \"$NVM_DIR/nvm.sh\" ] && \\\"$NVM_DIR/nvm.sh\\\"",
      "nvm install 20.18.0",
      "sudo unzip -o /tmp/backend.tar -d /var/www/api/",
      "sudo rm -rfdv /tmp/backend.tar",
      "for d in /var/www/api/*; do (cd $d && npm install --production && pm2 start index.js --name $(basename $d)); done",
      "sudo systemctl restart nginx"
    ]
  }

  tags = {
    Name = "services-backend"
  }
}