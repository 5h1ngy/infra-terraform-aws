variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to the SSH private key"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key"
}


variable "frontend_subnet_id" {
  type = string
}

variable "frontend_sg_id" {
  type        = string
  description = "The ID of the frontend security group"
}