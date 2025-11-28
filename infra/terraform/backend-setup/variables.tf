variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "eu-north-1"
}

variable "state_bucket_name" {
  description = "Name for the S3 bucket storing Terraform state (must be globally unique)"
  type        = string
  default     = "joeonome-microservice-state-001"  # Change this to make it unique
}

variable "dynamodb_table_name" {
  description = "Name for the DynamoDB table for state locking"
  type        = string
  default     = "terraform-locks"
}