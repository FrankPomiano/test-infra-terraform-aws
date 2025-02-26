/* This project creates a VPC with two subnets, one public and one private. It also creates all necessary
resources to guarantee connectivity to the internet from the public subnet.
*/

# Instantiate a single VPC using foundational models
module "base-vpc" {
  source               = "./modules/vpc-resources/vpc"
  PROJECT_NAME         = local.PROJECT_NAME
  ENV                  = local.ENV
  AWS_TAGS             = local.AWS_TAGS
  RESOURCE_SUFFIX      = "vpc"
  VPC_CIDR_BLOCK       = var.VPC_CIDR_BLOCKS[local.ENV]
  ENABLE_DNS_HOSTNAMES = true
}

# Instantiate an internet gateway for
module "internet-gateway" {
  source          = "./modules/vpc-resources/internet-gateway"
  PROJECT_NAME    = local.PROJECT_NAME
  ENV             = local.ENV
  AWS_TAGS        = var.AWS_TAGS
  RESOURCE_SUFFIX = "igw"
  VPC_ID          = module.base-vpc.id
}

#region Private Subnet
module "private_subnet_1a" {
  source            = "./modules/vpc-resources/subnet"
  PROJECT_NAME      = local.PROJECT_NAME
  ENV               = local.ENV
  RESOURCE_SUFFIX   = "private-1"
  AWS_TAGS          = merge(var.AWS_TAGS, tomap({ "Type" = "private" }))
  VPC_ID            = module.base-vpc.id
  AVAILABILITY_ZONE = "us-west-1a"
  CIDR_BLOCK        = var.PRIVATE_SUBNET_1A_CIDR_BLOCKS[local.ENV]
}

module "private_subnet_1b" {
  source            = "./modules/vpc-resources/subnet"
  PROJECT_NAME      = local.PROJECT_NAME
  ENV               = local.ENV
  RESOURCE_SUFFIX   = "private-2"
  AWS_TAGS          = merge(var.AWS_TAGS, tomap({ "Type" = "private" }))
  VPC_ID            = module.base-vpc.id
  AVAILABILITY_ZONE = "us-west-1b"
  CIDR_BLOCK        = var.PRIVATE_SUBNET_1B_CIDR_BLOCKS[local.ENV]
}

module "private_subnet_route_table" {
  source          = "./modules/vpc-resources/route-table"
  PROJECT_NAME    = local.PROJECT_NAME
  ENV             = local.ENV
  RESOURCE_SUFFIX = "private-subnet-rt"
  AWS_TAGS        = var.AWS_TAGS
  VPC_ID          = module.base-vpc.id
}

resource "aws_route_table_association" "private_subnet_1a" {
  subnet_id      = module.private_subnet_1a.id
  route_table_id = module.private_subnet_route_table.id
}

resource "aws_route_table_association" "private_subnet_1b" {
  subnet_id      = module.private_subnet_1b.id
  route_table_id = module.private_subnet_route_table.id
}
resource "aws_route" "private_subnet" {
  route_table_id         = module.private_subnet_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.nat-gateway.id
}
#endregion

#region Public Subnet
/* A public subnet is a subnet that is associated with a route table that has a route to
an Internet gateway
*/
module "public_subnet_1a" {
  source            = "./modules/vpc-resources/subnet"
  PROJECT_NAME      = local.PROJECT_NAME
  ENV               = local.ENV
  RESOURCE_SUFFIX   = "public-1"
  AWS_TAGS          = merge(var.AWS_TAGS, tomap({ "Type" = "public" }))
  VPC_ID            = module.base-vpc.id
  AVAILABILITY_ZONE = "us-west-1a"
  CIDR_BLOCK        = var.PUBLIC_SUBNET_1A_CIDR_BLOCKS[local.ENV]
}
module "public_subnet_1b" {
  source            = "./modules/vpc-resources/subnet"
  PROJECT_NAME      = local.PROJECT_NAME
  ENV               = local.ENV
  RESOURCE_SUFFIX   = "public-2"
  AWS_TAGS          = merge(var.AWS_TAGS, tomap({ "Type" = "public" }))
  VPC_ID            = module.base-vpc.id
  AVAILABILITY_ZONE = "us-west-1b"
  CIDR_BLOCK        = var.PUBLIC_SUBNET_1B_CIDR_BLOCKS[local.ENV]
}

module "public_subnet_route_table" {
  source          = "./modules/vpc-resources/route-table"
  PROJECT_NAME    = local.PROJECT_NAME
  ENV             = local.ENV
  RESOURCE_SUFFIX = "public-subnet-rt"
  AWS_TAGS        = var.AWS_TAGS
  VPC_ID          = module.base-vpc.id
}

resource "aws_route_table_association" "public_subnet_1a" {
  subnet_id      = module.public_subnet_1a.id
  route_table_id = module.public_subnet_route_table.id
}
resource "aws_route_table_association" "public_subnet_1b" {
  subnet_id      = module.public_subnet_1b.id
  route_table_id = module.public_subnet_route_table.id
}

# Routes traffic from public subnet to internet gateway test
resource "aws_route" "igw" {
  route_table_id         = module.public_subnet_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.internet-gateway.id
}

module "elastic-ip-for-nat-gateway" {
  source          = "./modules/vpc-resources/elastic-ip"
  PROJECT_NAME    = local.PROJECT_NAME
  ENV             = local.ENV
  RESOURCE_SUFFIX = "eip"
  AWS_TAGS        = var.AWS_TAGS
}

# NAT Gateways enables resources present in a private subnet to connect to the internet.
# NAT Gateways deployed in a public subnet must have an elastic IP address associated to it.
module "nat-gateway" {
  source          = "./modules/vpc-resources/nat-gateway"
  PROJECT_NAME    = local.PROJECT_NAME
  ENV             = local.ENV
  RESOURCE_SUFFIX = "nat-gateway"
  AWS_TAGS        = var.AWS_TAGS
  VPC_ID          = module.base-vpc.id
  SUBNET_ID       = module.public_subnet_1a.id
  ELASTIC_IP_ID   = module.elastic-ip-for-nat-gateway.id
}