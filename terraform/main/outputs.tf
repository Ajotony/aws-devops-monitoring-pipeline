output "server_ip" { 
  description = "public IP of EC2 instance"
  value = aws_instance.terraform_server.public_ip
}

output "instance_id" {
  value = aws_instance.terraform_server.public_ip
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
