# Creazione di un'istanza EC2 all'interno della subnet
resource "aws_instance" "ec2demo" {
  ami           = "ami-075449515af5df0d1" # Sostituisci con un'AMI valida per la tua regione
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.example.id
}
