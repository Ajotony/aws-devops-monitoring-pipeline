#This module is used only for bootstrapping the terraform backend resources.#Configure AWS provider

provider "aws" {
  region = var.aws_region
}

# S3 bucket to store terraform remote state
#This ensures state is accessible across environments
resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket_name

  # prevent accidental deletion of state bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "terraform-state-bucket"
    Environment = "bootstrap"
  }
}

# Enables rollback in case of state corruption
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB table for state locking, prevents concurrent terraform operations
resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-lock-table"
    Environment = "bootstrap"
  }
}
