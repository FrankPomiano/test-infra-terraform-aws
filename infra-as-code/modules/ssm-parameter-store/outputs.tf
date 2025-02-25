#Outputs

output "arn" {
  value       = aws_ssm_parameter.ssm_parameter.arn
  description = "Parameter Store arn"
}

output "parameter_value" {
  value       = aws_ssm_parameter.ssm_parameter.value
  description = "Parameter Store value"
}

output "parameter_name" {
  value       = aws_ssm_parameter.ssm_parameter.name
  description = "Parameter Store value"
}

output "parameter_name_net" {
  value       = "/${var.PROJECT_NAME}/${var.CONFIG}/${var.ENV}/"
  description = "Parameter Store value net framework"
}