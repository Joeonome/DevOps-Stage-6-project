variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key file for SSH access"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for EC2 instance"
  type        = string
  default     = "ubuntu"
}

variable "ansible_inventory_path" {
  description = "Path to write generated Ansible inventory"
  type        = string
}

variable "server_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "micro_service_server"
}
