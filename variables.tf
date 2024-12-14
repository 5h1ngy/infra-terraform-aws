variable "aws_access_key" {
  type        = string
  description = "Accessy key (configure inside tfvars)"
}

variable "aws_secret_key" {
  type        = string
  description = "Secret Key (configure inside tfvars)"
}

variable "aws_region" {
  type        = string
  description = "La regione AWS nella quale creare le risorse (configure inside tfvars)"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block per la VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  type        = string
  description = "CIDR block per la Subnet"
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  type        = string
  description = "Tipo di istanza EC2"
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID per l'istanza EC2"
  default     = "ami-075449515af5df0d1" # Sostituisci con un'AMI valida per la tua regione
}
