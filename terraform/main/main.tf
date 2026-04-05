# Security group for monitoring stack and SSH access
resource "aws_security_group" "firewall" {
  name_prefix = "firewall-config-"

  # Open ports required for monitoring stack and application access
  # N.B: 0.0.0.0/0 is used for testing purposes and should be restricted in production
  ingress { 
  description = "Allow SSH access"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Web traffic
  ingress {
    description = "HTTP traffic"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS traffic"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Monitoring ports
  ingress {
    description = "Grafana Dashboard"
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port = 9090
    to_port = 9090
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Alertmanager"
    from_port = 9093
    to_port = 9093
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "flask-app"
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
	
  egress {
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SSH key pair (public key injected via variable)
resource "aws_key_pair" "ssh_key" {
  key_name = "infra-pub-key"
  public_key = var.public_key
}

# Fetch latest ubuntu AMI dynamically
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical (ubuntu)

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 instance for monitoring stack
resource "aws_instance" "terraform_server" {
  ami =data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name = aws_key_pair.ssh_key.key_name

  vpc_security_group_ids = [
    aws_security_group.firewall.id
  ]

  tags = {
    Name = "terraform-server"
  }
}

# SNS topic used to send infrastructure alerts via email
resource "aws_sns_topic" "alerts" {
  name = "monitoring-alerts"
}


resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol = "email"
  endpoint = var.alert_email
}

# Triggers alert when EC2 instance fails status checks
# Used for infrastructure level monitoring (seperate from application alerts)
resource "aws_cloudwatch_metric_alarm" "ec2_failed_status_check" {
  alarm_name = "ec2-status-check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  metric_name = "StatusCheckFailed"
  namespace = "AWS/EC2"
  period = 60
  statistic = "Maximum"
  threshold = 1

  alarm_description = "EC2 Instance status check failed"

  dimensions = {
    InstanceId = aws_instance.terraform_server.id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

}

