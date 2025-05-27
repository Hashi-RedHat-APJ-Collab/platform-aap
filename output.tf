# Output values

output "public_ip" {
  value = aws_instance.aap_instance.public_ip
}

output "public_fqdn" {
  value = aws_instance.aap_instance.public_dns
}

output "instance_id" {
  value = aws_instance.aap_instance.id
}

output "efs_dns_name" {
  value = aws_efs_file_system.efs.dns_name
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.aap_alb.dns_name
}

output "alb_log_bucket_name" {
  value = aws_s3_bucket.alb_logs.bucket
}