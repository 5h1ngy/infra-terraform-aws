# Creazione di un Internet Gateway per fornire accesso a Internet
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "example-igw"
  }
}
