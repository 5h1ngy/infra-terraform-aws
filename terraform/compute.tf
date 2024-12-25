resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key"
  public_key = file("./data/ssh/id_rsa.pub")
}

resource "aws_instance" "backend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.backend.id

  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  key_name = aws_key_pair.terraform_key.key_name

  # Configurazione del disco root
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
      "mkdir -p /home/ubuntu/services/backend"
    ]
  }

  # Copia i progetti Node.js sulla macchina EC2
  provisioner "file" {
    source      = "./data/services/backend.zip"
    destination = "/home/ubuntu/backend.zip"
  }

  # Docker compose & nginx
  provisioner "file" {
    source      = "./data/templates/docker-compose-backend.yml"
    destination = "/home/ubuntu/docker-compose.yml"
  }
  provisioner "file" {
    source      = "./data/templates/Dockerfile-backend.yml"
    destination = "/home/ubuntu/Dockerfile.yml"
  }
  # Copia il file Nginx manuale sulla macchina
  provisioner "file" {
    source      = "./data/templates/nginx-backend.conf"
    destination = "/home/ubuntu/nginx/nginx-backend.conf"
  }

  # Certificati
  provisioner "file" {
    source      = "./data/ssl/certificate.crt"
    destination = "/home/ubuntu/ssl/certificate.crt"
  }

  provisioner "file" {
    source      = "./data/ssl/private.key"
    destination = "/home/ubuntu/ssl/private.key"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu" # Cambia in base all'AMI usata
    private_key = file("./data/ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y docker.io unzip",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",

      # Installazione Docker Compose
      "sudo curl -L \"https://github.com/docker/compose/releases/download/v2.25.0/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",

      # Creazione directory per il backend
      "sudo unzip -o /home/ubuntu/backend.zip -d /home/ubuntu/services/backend",

      # Debug per verificare i file e le directory
      "ls -lpa /home/ubuntu",
      "ls -lpa /home/ubuntu/ssl",
      "ls -lpa /home/ubuntu/nginx",
      "ls -lpa /home/ubuntu/services/backend",

      # Avvio del container Nginx
      "cd /home/ubuntu && sudo docker-compose --file /home/ubuntu/docker-compose.yml up --detach",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo '127.0.0.1 be-node-portfolio-service' | sudo tee -a /etc/hosts",
      "echo '127.0.0.1 reverse-proxy-service' | sudo tee -a /etc/hosts"
    ]
  }

  tags = {
    Name = "services-backend"
  }
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
    source      = "./data/services/frontend.zip"
    destination = "/home/ubuntu/frontend.zip"
  }

  # Docker compose & nginx
  provisioner "file" {
    source      = "./data/templates/docker-compose-frontend.yml"
    destination = "/home/ubuntu/docker-compose.yml"
  }
  provisioner "file" {
    source      = "./data/templates/nginx-frontend.conf"
    destination = "/home/ubuntu/nginx/nginx-frontend.conf"
  }

  # Certificati
  provisioner "file" {
    source      = "./data/ssl/certificate.crt"
    destination = "/home/ubuntu/ssl/certificate.crt"
  }

  provisioner "file" {
    source      = "./data/ssl/private.key"
    destination = "/home/ubuntu/ssl/private.key"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu" # Cambia in base all'AMI usata
    private_key = file("./data/ssh/id_rsa")
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
      "sudo unzip -o /home/ubuntu/frontend.zip -d /home/ubuntu/services/frontend",

      # Debug per verificare i file e le directory
      "ls -lpa /home/ubuntu",
      "ls -lpa /home/ubuntu/nginx",
      "ls -lpa /home/ubuntu/ssl",
      "ls -lpa /home/ubuntu/services/frontend",

      # Nginx Template rewrite
      "sudo sed -i 's|<BACKEND_IP>|${aws_instance.backend.private_ip}|g' /home/ubuntu/nginx/nginx-frontend.conf",

      # Avvio del container Nginx
      "cd /home/ubuntu && sudo docker-compose --file /home/ubuntu/docker-compose.yml up --detach",
    ]
  }

  tags = {
    Name = "services-frontend"
  }
}
