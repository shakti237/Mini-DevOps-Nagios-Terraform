output "web_instance_public_ip" {
  description = "Public IP of the web (application) server"
  value       = aws_instance.web.public_ip
}

output "monitor_instance_public_ip" {
  description = "Public IP of the Nagios monitoring server"
  value       = aws_instance.monitor.public_ip
}

output "web_instance_private_ip" {
  description = "Private IP of the web server (used for NRPE)"
  value       = aws_instance.web.private_ip
}

output "monitor_instance_private_ip" {
  description = "Private IP of the monitor server"
  value       = aws_instance.monitor.private_ip
}

output "nagios_web_url" {
  description = "Nagios web UI URL"
  value       = "http://${aws_instance.monitor.public_ip}:8080/nagios"
}
