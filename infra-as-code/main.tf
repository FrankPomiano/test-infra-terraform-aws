data "aws_region" "current_region" {}
data "aws_caller_identity" "current" {}

locals {
  PROJECT_NAME   = "belcorp-0001-demo-fpm"
  ENV            = terraform.workspace
  AWS_REGION     = data.aws_region.current_region.name
  AWS_TAGS       = merge(var.AWS_TAGS, tomap({ "Environment" = terraform.workspace }))
  AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
}

module "ecs-cluster-for-dbt" {
  source          = "./modules/ecs-cluster"
  PROJECT_NAME    = local.PROJECT_NAME
  ENV             = local.ENV
  RESOURCE_SUFFIX = "cluster-for-dbt"
  AWS_TAGS        = var.AWS_TAGS
}


module "load-balancer" {
  source              = "./modules/load-balancer"
  ENV                 = local.ENV
  PROJECT_NAME        = local.PROJECT_NAME
  AWS_TAGS            = local.AWS_TAGS
  RESOURCE_SUFFIX     = "alb"
  SUBNET_PUBLICS      = [module.public_subnet_1a.id,module.public_subnet_1b.id] # 2 subnets in different AZs
  VPC_ID              = module.base-vpc.id
  SECURITY_GROUP_ID   = module.alb-security-group.id
  CERTIFICATE_ARN       = var.CERTIFICATE_ARN[local.ENV]
  ROUTE_53_ZONE_ID       = var.ROUTE_53_ZONE_ID[local.ENV]
  DOMAIN_NAME_BACKEND       = var.DOMAIN_NAME_BACKEND[local.ENV]
}

module "alb-security-group" {
  source                     = "./modules/vpc-resources/security-group"
  PROJECT_NAME               = local.PROJECT_NAME
  ENV                        = local.ENV
  RESOURCE_SUFFIX            = "alb"
  AWS_TAGS                   = var.AWS_TAGS
  VPC_ID                     = module.base-vpc.id
  SECURITY_GROUP_DESCRIPTION = "security group for ALB"
  EGRESS_RULES = [
    {
      description      = "Egress rule for general purpose SG"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]
  INGRESS_RULES = [
    {
      description              = "Full ingress for HTTP"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      cidr_blocks              = ["0.0.0.0/0"]
      ipv6_cidr_blocks         = []
      source_security_group_id = ""
    },
    {
      description              = "Full ingress for HTTPS"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      cidr_blocks              = ["0.0.0.0/0"]
      ipv6_cidr_blocks         = []
      source_security_group_id = ""
    }
  ]
}

module "ssm-parameters-store-app" {
  source          = "./modules/ssm-parameter-store"
  PROJECT_NAME    = local.PROJECT_NAME
  ENV             = local.ENV
  RESOURCE_SUFFIX = "tableName"
  AWS_TAGS        = var.AWS_TAGS
  CONFIG          = "config"
  VALUE           = "tableName-value"
  TYPE            = "String"
}

module "ecs-task-definition" {
  source              = "./modules/ecs-task-definition"
  ENV                 = local.ENV
  PROJECT_NAME        = local.PROJECT_NAME
  AWS_TAGS            = local.AWS_TAGS
  RESOURCE_SUFFIX     = "task-definition-for-dbt"
  ECR_REPOSITORY_URL  = module.ecr-repository.repository_url
  ECR_IMAGE_TAG      = "latest"
  DBT_ECS_CLUSTER_ARN = module.ecs-cluster-for-dbt.arn
  APP_ENVIRONMENTS_VARS = [{ "name" = "APP_PARAMS_PREFIX", "value" = module.ssm-parameters-store-app.parameter_name_net }]
}

module "services-security-group" {
  source                     = "./modules/vpc-resources/security-group"
  PROJECT_NAME               = local.PROJECT_NAME
  ENV                        = local.ENV
  RESOURCE_SUFFIX            = "services"
  AWS_TAGS                   = var.AWS_TAGS
  VPC_ID                     = module.base-vpc.id
  SECURITY_GROUP_DESCRIPTION = "security group for ecs services"
  EGRESS_RULES = [
    {
      description      = "Egress rule for general purpose SG"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]
  INGRESS_RULES = [
    {
      description              = "Ingress for HTTP ALB"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      cidr_blocks              = []
      ipv6_cidr_blocks         = []
      source_security_group_id = module.alb-security-group.id
    }
  ]
}
module "ecr-repository" {
  source          = "./modules/ecr"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  AWS_TAGS        = local.AWS_TAGS
  RESOURCE_SUFFIX = "images-repository"
}

module "ecs-cluster-resources-security-group" {
  source = "./modules/networking"
  ENV             = local.ENV
  PROJECT_NAME    = local.PROJECT_NAME
  VPC_ID          = module.base-vpc.id
}
