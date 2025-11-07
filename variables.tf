# AWS Region
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

# VPC ID
variable "vpc_id" {
  description = "VPC ID where the instances will be launched"
  type        = string
}

# Subnet ID
variable "subnet_id" {
  description = "Subnet ID for the instances"
  type        = string
}

# Instance Type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Ubuntu AMI ID
variable "ubuntu_ami" {
  description = "Ubuntu 24.04 AMI ID for your region"
  type        = string
  default     = "ami-087d1c9a513324697" # ap-south-1 (update if needed)
}

# SSH Key Name (existing key in AWS)
variable "key_name" {
  description = "Name of the existing AWS key pair to use"
  type        = string
  default     = "practice"
}

# Optional — Only if you use aws_key_pair resource (otherwise unused)
variable "public_key_path" {
  description = "Path to your public key file"
  type        = string
  default     = "~/.ssh/practice.pub"
}
