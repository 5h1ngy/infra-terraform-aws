# main.tf
module "networking" {
  source             = "./modules/networking"
  vpc_cidr_block     = var.vpc_cidr_block
  subnet_cidr_block  = var.subnet_cidr_block
}

module "compute" {
  source        = "./modules/compute"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.networking.subnet_id
}


variable "ami_id" {
  type        = string
  description = "AMI ID per l'istanza EC2"
}

variable "instance_type" {
  type        = string
  description = "Tipo di istanza EC2"
}

variable "subnet_frontend_id" {
  type        = string
  description = "ID della subnet in cui lanciare l'istanza EC2"
}

variable "subnet_backend_id" {
  type        = string
  description = "ID della subnet in cui lanciare l'istanza EC2"
}