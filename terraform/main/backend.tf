terraform {
  backend "s3" {
    bucket = "infra-tf-state-bucket-remote-100"
    key = "main/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "infra-state-lock-table"
  }
}

provider "aws" {
  region = var.aws_region
}
