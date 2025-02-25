# Locals section
locals {
  RESOURCE_NAME = "${var.PROJECT_NAME}-${var.ENV}-${var.RESOURCE_SUFFIX}"
  SSM_NAME = "/${var.PROJECT_NAME}/${var.CONFIG}/${var.ENV}/${var.RESOURCE_SUFFIX}"
}


resource "aws_ssm_parameter" "ssm_parameter" {
  name  = local.SSM_NAME
  type  = var.TYPE
  value = var.VALUE
  tags = merge(var.AWS_TAGS, {
    Name = local.RESOURCE_NAME
  })
}