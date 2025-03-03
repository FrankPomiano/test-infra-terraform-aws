variable "ENV" {}

variable "AWS_TAGS" {}

variable "PROJECT_NAME" {}

variable "LOG_RETENTION_IN_DAYS" {
  type    = number
  default = 30
}

variable "RESOURCE_SUFFIX" {}

variable "DBT_ECS_CLUSTER_ARN" {}

variable "ECR_REPOSITORY_URL" {}


variable "ECR_IMAGE_TAG" {}

variable "APP_ENVIRONMENTS_VARS" {
  type        = list(map(string))
  default     = []
  description = "environment variable needed by the application"
}