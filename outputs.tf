output "elb_dns_name" {
  description = "DNS name of the Elastic Load Balancer"
  value       = aws_elb.nginx_elb.dns_name
}
    