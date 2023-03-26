###################################################
#--------moduel networking for vpc,subnets,routes,IG,nat-GW------------

module "Network" {
  source               = "./Network"
  name                 = var.name
  cidr_block           = var.cidr_block
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy     = var.instance_tenancy
  environment          = var.environment
  aws_region           = var.aws_region
  requestor            = var.requestor
  customer             = var.customer
  tenant               = var.tenant
  product              = var.product
  manager              = var.manager
  owner                = var.owner
  purpose              = var.purpose
}

###################################################
#--------moduel for ECS creation------------
module "ECS" {
  source          = "./ECS"
  name            = var.name
  environment     = var.environment
  vpc_id          = module.Network.vpc_id
  private_subnet  = module.Network.private_subnet
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  public_subnet  = module.Network.public_subnet
  aws_region      = var.aws_region
  ecs_base_ami_name = var.ecs_base_ami_name
  ecs_instance_type = var.ecs_instance_type
  ecs_volume_size = var.ecs_volume_size
  ecs_max_size = var.ecs_max_size
  ecs_min_size = var.ecs_min_size
  ecs_desired_capacity = var.ecs_desired_capacity
  requestor = var.requestor
  customer = var.customer
  tenant = var.tenant
  product = var.product
  manager = var.manager
  owner = var.owner
  purpose = var.purpose
}