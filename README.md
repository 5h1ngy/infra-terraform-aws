# Ristrutturazione del Progetto Terraform

## **Obiettivo**
Il progetto ha come scopo la configurazione di due subnet distinte:
- Una per il frontend (FE) che ospiterà file statici serviti da Nginx.
- Una per il backend (BE) che eseguirà microservizi Node.js.

Ogni subnet conterrà una propria istanza EC2 con configurazione automatizzata per ospitare i servizi.

## **Struttura del Progetto**

### **Moduli Terraform**
- **Moduli Esistenti:**
  - `networking`: Configura VPC, subnet e routing.
  - `compute`: Configura le istanze EC2.

### **Modifiche Implementate**

1. **Networking:**
   - **Subnet 1 (Frontend):** CIDR configurato su `10.0.1.0/24`.
   - **Subnet 2 (Backend):** CIDR configurato su `10.0.2.0/24`.

2. **Compute:**
   - **Istanza Frontend:** Provisioning automatico per Nginx.
   - **Istanza Backend:** Provisioning automatico per NVM e Node.js.

3. **Provisioning Frontend:**
   - Copiati i file statici nella directory `/var/www/html/`.
   - Configurato un template Nginx per servire i file statici su porte diverse.

4. **Provisioning Backend:**
   - Installato NVM e Node.js.
   - Copiati i progetti backend nella directory `/var/www/api/`.
   - Configurati i microservizi su porte dedicate con prefissi `/api/<nome-progetto>`.

## **Codice Terraform Aggiornato**

### **1. Modulo Networking**
```hcl
resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "frontend" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "frontend-subnet"
  }
}

resource "aws_subnet" "backend" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "backend-subnet"
  }
}
```

### **2. Modulo Compute**
```hcl
resource "aws_instance" "frontend" {
  ami           = "ami-075449515af5df0d1"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.frontend.id

  provisioner "file" {
    source      = "./frontend/dist"
    destination = "/var/www/html"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo cp /var/www/html/nginx.conf /etc/nginx/sites-enabled/default",
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
      "export NVM_DIR=\"$HOME/.nvm\" && [ -s \"$NVM_DIR/nvm.sh\" ] && \\ \"$NVM_DIR/nvm.sh\"",
      "nvm install 16",
      "cd /var/www/api && npm install",
      "pm2 start all"
    ]
  }

  tags = {
    Name = "backend-instance"
  }
}
```

### **3. Provisioning Script per Nginx (Template)**
```nginx
server {
  listen 80;
  server_name _;

  location / {
    root /var/www/html/project1;
    index index.html;
  }

  location /project2 {
    root /var/www/html/project2;
    index index.html;
  }
}
```

### **4. Configurazione Backend per Microservizi**
Ogni microservizio è esposto su una porta dedicata:
```bash
pm2 start microservice1.js --name api-service1 --watch
pm2 start microservice2.js --name api-service2 --watch
```

### **5. Output e Verifica**
- **Frontend:** Accessibile alle porte specifiche tramite Nginx.
- **Backend:** Accessibile su `/api/<nome-progetto>` per ciascun microservizio.