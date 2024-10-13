output "ecr_repository_url" {
  value = aws_ecr_repository.callsign.repository_url
}

output "load_balancer_url" {
  value = aws_lb.callsign.dns_name
}
