################################################################################
# Load Balancer
################################################################################

output "id" {
  description = "The ID and ARN of the load balancer we created"
  value       =  aws_lb.application-load-balancer.id
}

output "arn" {
  description = "The ID and ARN of the load balancer we created"
  value       = aws_lb.application-load-balancer.arn
}

output "arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch"
  value       = aws_lb.application-load-balancer.arn_suffix
}

output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.application-load-balancer.dns_name
}

output "zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records"
  value       = aws_lb.application-load-balancer.zone_id
}

################################################################################
# Listener(s)
################################################################################

output "listeners" {
  description = "Map of listeners created and their attributes"
  value       = aws_lb_listener.lb-listener-443-forwar.arn
  sensitive   = true
}


#################################################################################
## Target Group(s)
#################################################################################

output "target_groups" {
  description = "Map of target groups created and their attributes"
  value       = aws_lb_target_group.target-group-80.arn
}

#################################################################################
## Route 53
#################################################################################

output "aws_route53_record" {
  description = "aws_route53_record record for the load balancer"
  value       = aws_route53_record.domain_name.alias
}