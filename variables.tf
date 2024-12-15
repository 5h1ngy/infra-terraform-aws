# AWS Credentials (Sensitive Information - No Default Values)
variable "aws_access_key" {
  type        = string
  description = "Access key (configure inside tfvars)"
}

variable "aws_secret_key" {
  type        = string
  description = "Secret Key (configure inside tfvars)"
}

# AWS Region
variable "aws_region" {
  type        = string
  description = "AWS Region for deploying resources"
  default     = "eu-north-1"
}

# Network Configuration

# CIDR Block for the VPC
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# CIDR Block for the Frontend Subnet
variable "frontend_cidr_block" {
  type        = string
  description = "CIDR block for the frontend subnet"
  default     = "10.0.1.0/24"
}

# CIDR Block for the Backend Subnet
variable "backend_cidr_block" {
  type        = string
  description = "CIDR block for the backend subnet"
  default     = "10.0.2.0/24"
}

# Instance Configuration

# AMI ID for the EC2 instances
variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instances"
  default     = "ami-075449515af5df0d1"
}

# Instance type for the EC2 instances
variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instances"
  default     = "t3.nano"
}

# SSH Configuration

# Path to the SSH private key

variable "ssh_private_key_path" {
  type        = string
  description = "Path to the SSH private key"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key"
}
