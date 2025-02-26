variable "AWS_TAGS" {
  type = map(string)
  default = {
    "Project Name"        = "alicorp-0000-demo"
    "Project Description" = "Esta demo presenta el despliegue mediante Github Action - Terraform - ECS Fargete"
    "Sector"              = "DevOps Engineer"
    "Company"             = "CORPORACION ROMERO GROUP"
    "Cost center"         = "0000"
  }
}

variable "VPC_CIDR_BLOCKS" {
  type = map(string)
  default = {
    dev = "192.168.0.0/16"
    qa  = "11.0.0.0/16"
    stg = "192.168.0.0/16"
    prd = "192.168.0.0/16"
  }
}

variable "PRIVATE_SUBNET_1A_CIDR_BLOCKS" {
  type = map(string)
  default = {
    dev = "192.168.0.0/24"
    qa  = "11.0.0.0/24"
    stg = "192.168.0.0/24"
    prd = "192.168.0.0/24"
  }
}
variable "PRIVATE_SUBNET_1B_CIDR_BLOCKS" {
  type = map(string)
  default = {
    dev = "192.168.1.0/24"
    qa  = "11.0.1.0/24"
    stg = "192.168.1.0/24"
    prd = "192.168.1.0/24"
  }
}

variable "PUBLIC_SUBNET_1A_CIDR_BLOCKS" {
  type = map(string)
  default = {
    dev = "192.168.3.0/24"
    qa  = "11.0.3.0/24"
    stg = "192.168.3.0/24"
    prd = "192.168.3.0/24"
  }
}
variable "PUBLIC_SUBNET_1B_CIDR_BLOCKS" {
  type = map(string)
  default = {
    dev = "192.168.4.0/24"
    qa  = "11.0.4.0/24"
    stg = "192.168.4.0/24"
    prd = "192.168.4.0/24"
  }
}

variable "CERTIFICATE_ARN" {
  type = map(string)
  default = {
    dev = "arn:aws:acm:us-west-1:467449736571:certificate/18ace870-e4e8-4e15-b486-c55e70eb9f14"
    qa  = "arn:aws:acm:us-west-1:467449736571:certificate/18ace870-e4e8-4e15-b486-c55e70eb9f14"
    stg = "arn:aws:acm:us-west-1:467449736571:certificate/18ace870-e4e8-4e15-b486-c55e70eb9f14"
    prd = "arn:aws:acm:us-west-1:467449736571:certificate/18ace870-e4e8-4e15-b486-c55e70eb9f14"
  }
}
variable "ROUTE_53_ZONE_ID" {
  type = map(string)
  default = {
    dev = "Z0060444W0LEND70FDJI"
    qa  = "Z0060444W0LEND70FDJI"
    stg = "Z0060444W0LEND70FDJI"
    prd = "Z0060444W0LEND70FDJI"
  }
}
variable "DOMAIN_NAME_BACKEND" {
  type = map(string)
  default = {
    dev = "api.testfpmbelcorp.applying.cloud"
    qa  = "api.testfpmbelcorp.applying.cloud"
    stg = "api.testfpmbelcorp.applying.cloud"
    prd = "api.testfpmbelcorp.applying.cloud"
  }
}