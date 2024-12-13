# Creazione di un Internet Gateway per fornire accesso a Internet alle risorse nella VPC
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id                  # Associa l'Internet Gateway alla VPC creata sopra
  tags = {
    Name = "example-igw"                       # Etichetta identificativa per l'Internet Gateway
  }
}
# Creazione di una tabella di routing per gestire il traffico nella VPC
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id                  # Associa la tabella di routing alla VPC
  route {
    cidr_block = "0.0.0.0/0"                   # Regola di routing per consentire il traffico verso Internet
    gateway_id = aws_internet_gateway.example.id # Utilizza l'Internet Gateway per instradare il traffico
  }
  tags = {
    Name = "example-route-table"               # Etichetta identificativa per la tabella di routing
  }
}

# Associazione della tabella di routing alla subnet creata sopra
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.example.id       # Associa la subnet alla tabella di routing
  route_table_id = aws_route_table.example.id  # Specifica la tabella di routing da associare
}

# Creazione di una VPC (Virtual Private Cloud) che definisce una rete virtuale isolata
resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16" # Intervallo IP per la rete; qui consente 65.536 indirizzi (maschera /16)
  enable_dns_support   = true         # Abilita il supporto per il DNS per risolvere nomi di dominio interni
  enable_dns_hostnames = true         # Genera automaticamente hostname DNS per le istanze nella VPC
  tags = {
    Name = "example-vpc"              # Etichetta identificativa per facilitare la gestione della risorsa
  }
}

# Creazione di una subnet all'interno della VPC per contenere risorse specifiche
resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.example.id       # Associa la subnet alla VPC creata sopra
  cidr_block        = "10.0.1.0/24"            # Intervallo IP della subnet; supporta fino a 256 indirizzi
  map_public_ip_on_launch = true               # Assegna automaticamente un IP pubblico alle istanze lanciate
  tags = {
    Name = "example-subnet"                    # Etichetta identificativa per la subnet
  }
}

# Creazione di un'istanza EC2 all'interno della subnet
resource "aws_instance" "ec2demo" {
  ami           = "ami-075449515af5df0d1"      # Identificatore dell'AMI (Amazon Machine Image); scegli un AMI valido per la tua regione
  instance_type = "t3.micro"                   # Tipo di istanza (specifica CPU, RAM e prestazioni)
  subnet_id     = aws_subnet.example.id        # Specifica la subnet in cui lanciare l'istanza
}
