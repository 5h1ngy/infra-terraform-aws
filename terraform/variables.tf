# ---------------------------
# 1. AWS Credentials (Scope: Global - Sensitive Information)
# ---------------------------
variable "aws_access_key" {
  type        = string
  description = "Access key for AWS account (configure inside tfvars)"
}

variable "aws_secret_key" {
  type        = string
  description = "Secret key for AWS account (configure inside tfvars)"
}

# ---------------------------
# 2. AWS Region (Scope: Global - Deployment Configuration)
# ---------------------------
variable "aws_region" {
  type        = string
  description = "AWS Region where resources will be deployed"
  default     = "eu-north-1"
}

# ---------------------------
# 3. Networking Configuration (Scope: Infrastructure)
# ---------------------------

# VPC Configuration
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the Virtual Private Cloud (VPC)"
  default     = "10.0.0.0/16"
}

# Subnet Configuration
variable "frontend_cidr_block" {
  type        = string
  description = "CIDR block for the frontend subnet"
  default     = "10.0.1.0/24"
}

variable "backend_cidr_block" {
  type        = string
  description = "CIDR block for the backend subnet"
  default     = "10.0.2.0/24"
}

# ---------------------------
# 4. EC2 Instance Configuration (Scope: Compute Resources)
# ---------------------------
variable "ami_id" {
  type        = string
  description = "Amazon Machine Image (AMI) ID for EC2 instances"
  default     = "ami-075449515af5df0d1"
}

variable "instance_type" {
  type        = string
  description = "Instance type for EC2 instances"
  default     = "t3.nano"
}

# ---------------------------
# 5. SSH Configuration (Scope: Remote Access)
# ---------------------------
variable "ssh_private_key_path" {
  type        = string
  description = "Path to the SSH private key for remote access"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key for key pair configuration"
}
