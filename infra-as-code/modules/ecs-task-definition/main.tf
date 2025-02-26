data "aws_region" "aws_account_region" {}
locals {
  RESOURCE_NAME = "${var.PROJECT_NAME}-${var.ENV}-${var.RESOURCE_SUFFIX}"
  AWS_REGION    = data.aws_region.aws_account_region.name
}

module "logging" {
  source = "./logging"
  LOGGING_SETTINGS = {
    "ecs_cluster_name"      = local.RESOURCE_NAME
    "log_retention_in_days" = var.LOG_RETENTION_IN_DAYS
  }
}

module "permissions" {
  source          = "./permissions"
  PROJECT_NAME    = var.PROJECT_NAME
  AWS_TAGS        = var.AWS_TAGS
  ENV             = var.ENV
  ECS_CLUSTER_ARN = var.DBT_ECS_CLUSTER_ARN
  ECS_TASK_ARN    = aws_ecs_task_definition.task_definition.arn
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = local.RESOURCE_NAME
  execution_role_arn       = module.permissions.ecs-task-execution-service-role-arn
  task_role_arn            = module.permissions.dbt-fargate-task-role-arn
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags                     = var.AWS_TAGS
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions    = <<EOF
[
  {
    "name": "${local.RESOURCE_NAME}-container",
    "image": "${var.ECR_REPOSITORY_URL}:${var.ECR_IMAGE_TAG}",
    "environment": ${jsonencode(var.APP_ENVIRONMENTS_VARS)},
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "cpu": 1024,
    "memory": 2048,
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${local.AWS_REGION}",
        "awslogs-group": "/aws/ecs/${local.RESOURCE_NAME}",
        "awslogs-stream-prefix": "ecs/${var.PROJECT_NAME}-${var.ENV}"
      }
    }
  }
]
EOF
}