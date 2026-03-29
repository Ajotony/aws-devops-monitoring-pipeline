variable "aws_region" {
  description = "AWS region"
  type = string
  default = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type = string
}

variable "public_key" {
  description = "Public SSH key"
  type = string
}

variable "alert_email" {
  description = "Email for receiving alerts"
  type = string
}
