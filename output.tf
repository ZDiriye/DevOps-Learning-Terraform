output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "endpoint" {
  value = module.rds.endpoint
}
