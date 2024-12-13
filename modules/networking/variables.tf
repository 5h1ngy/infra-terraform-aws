# modules/networking/variables.tf
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block per la VPC"
}

variable "subnet_cidr_block" {
  type        = string
  description = "CIDR block per la Subnet"
}
