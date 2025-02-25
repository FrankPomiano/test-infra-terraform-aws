# Variables section

variable "PROJECT_NAME" {
  description = "The name of the project"
}

variable "CONFIG" {
  description = "The Config name"
}

variable "ENV" {
  description = "The environment (e.g., dev, prod)"
}
variable "RESOURCE_SUFFIX" {
  description = "Suffix for the resource name"
}

variable "VALUE" {
  description = "The value of the resource"
}

variable "TYPE" {
  description = "The tipe of the resource string, secret, etc"
}


variable "AWS_TAGS" {
  description = <<EOF
  Tags are key-value pairs that provide metadata and labeling to resources for better management.
EOF
  type        = map(string)
}
