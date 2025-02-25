data "aws_region" "aws_account_region" {}
locals {
  RESOURCE_NAME = "${var.PROJECT_NAME}-${var.ENV}-${var.RESOURCE_SUFFIX}"
  AWS_REGION    = data.aws_region.aws_account_region.name
}


resource "aws_ecs_service" "ecs-services-app" {
  cluster = var.ECS_CLUSTER_ARN
  desired_count = 1
  launch_type = "FARGATE"
  platform_version = "LATEST"
  enable_execute_command= true
  name = local.RESOURCE_NAME
  task_definition = var.ECS_TASK_DEFINITION_ARN

  lifecycle {
    ignore_changes = [task_definition] ## Ignore changes to task definition
  }

  load_balancer {
    container_name = var.CONTAINER_NAME
    container_port = 80
    target_group_arn = var.ALB_TARGET_GROUP_ARN
  }

  network_configuration {
    security_groups = [var.SECURITY_GROUP_ID]
    subnets = [for subnet in var.SUBNET_PRIVATES : subnet]
  }
}