variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "S3 bucket name for terraform remote state"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for terraform state locking"
  type        = string
}
