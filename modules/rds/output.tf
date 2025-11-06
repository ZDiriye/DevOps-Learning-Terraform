output "endpoint" {
  description = "DNS endpoint of the MySQL instance"
  value       = aws_db_instance.wp.address
}

