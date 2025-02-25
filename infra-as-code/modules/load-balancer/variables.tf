variable "ENV" {}

variable "AWS_TAGS" {}

variable "PROJECT_NAME" {}

variable "RESOURCE_SUFFIX" {}

variable "SUBNET_PUBLICS" {
  type = list(string)
  default = []
}
variable "VPC_ID" {}
variable "SECURITY_GROUP_ID" {}
variable "CERTIFICATE_ARN" {}
variable "ROUTE_53_ZONE_ID" {}
variable "DOMAIN_NAME_BACKEND" {}