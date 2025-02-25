variable "ENV" {}

variable "AWS_TAGS" {}

variable "PROJECT_NAME" {}

variable "RESOURCE_SUFFIX" {}

variable "SUBNET_PRIVATES" {
  type = list(string)
  default = []
}
variable "SECURITY_GROUP_ID" {}
variable "ECS_CLUSTER_ARN" {}
variable "ECS_TASK_DEFINITION_ARN" {}
variable "ALB_TARGET_GROUP_ARN" {}
variable "CONTAINER_NAME" {}