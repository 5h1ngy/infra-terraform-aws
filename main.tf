module "networking" {
  source              = "./modules/networking"
  vpc_cidr_block      = var.vpc_cidr_block
  frontend_cidr_block = var.frontend_cidr_block
  backend_cidr_block  = var.backend_cidr_block
}

module "security" {
  source = "./modules/security"
  vpc_id = module.networking.vpc_id
}

module "compute" {
  source               = "./modules/compute"
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  frontend_subnet_id   = module.networking.frontend_subnet_id
  frontend_sg_id       = module.security.frontend_sg_id
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path  = var.ssh_public_key_path
}
