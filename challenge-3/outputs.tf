# Outputs
output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.dns_name
}

output "rds_endpoint" {
  description = "RDS Cluster endpoint"
  value       = module.rds.this_rds_cluster_endpoint
}
