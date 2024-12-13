# modules/compute/variables.tf
variable "ami_id" {
  type        = string
  description = "AMI ID per l'istanza EC2"
}

variable "instance_type" {
  type        = string
  description = "Tipo di istanza EC2"
}

variable "subnet_id" {
  type        = string
  description = "ID della subnet in cui lanciare l'istanza EC2"
}
