provider "aws" {
  region = var.aws_region
}

# =====================================================
# SECURITY GROUP (for both Web & Monitor instances)
# =====================================================
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Allow SSH, HTTP, NRPE, and Nagios access"
  vpc_id      = var.vpc_id

  # SSH Access
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Access (for Nginx)
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nagios Web UI Access
  ingress {
    description = "Allow Nagios Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NRPE Access (within default VPC range)
  ingress {
    description = "Allow NRPE within VPC"
    from_port   = 5666
    to_port     = 5666
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"] # ✅ Corrected CIDR for default VPC
  }

  # Allow Ping/ICMP (optional but useful for debugging)
  ingress {
    description = "Allow ICMP (Ping)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow All Outbound Traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-sg"
  }
}

# =====================================================
# WEB SERVER (Nginx + Redis + NRPE)
# =====================================================
resource "aws_instance" "web" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.monitoring_sg.id]
  key_name                    = "practice"
  associate_public_ip_address = true
  user_data                   = file("${path.module}/userdata_web.sh")

  tags = {
    Name = "ubuntu-web-server"
  }
}

# =====================================================
# MONITORING SERVER (Nagios + NRPE)
# =====================================================
resource "aws_instance" "monitor" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.monitoring_sg.id]
  key_name                    = "practice"
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/userdata_monitor.tpl", {
    web_private_ip = aws_instance.web.private_ip
  })

  depends_on = [aws_instance.web]

  tags = {
    Name = "ubuntu-monitor-server"
  }
}
