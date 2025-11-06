module "vpc" {
  source = "./modules/vpc"
}

module "public_subnets" {
  source = "./modules/public_subnets"

  vpc_id = module.vpc.vpc_id
  igw_id = module.vpc.igw_id
}

module "private_subnets" {
  source = "./modules/private_subnets"

  vpc_id       = module.vpc.vpc_id
  nat_gateway1 = module.nat_gateway.nat_gateway1
  nat_gateway2 = module.nat_gateway.nat_gateway2
}

module "public_ec2" {
  source = "./modules/public_ec2"

  vpc_id            = module.vpc.vpc_id
  public_subnet1_id = module.public_subnets.public_subnet1_id
  public_subnet2_id = module.public_subnets.public_subnet2_id
}

module "private_ec2" {
  source               = "./modules/private_ec2"
  depends_on           = [module.nat_gateway]
  vpc_id               = module.vpc.vpc_id
  bastion_host_sg_id   = module.public_ec2.bastion_host_sg_id
  alb_sg_id            = module.alb.alb_sg_id
  private_subnet1_id   = module.private_subnets.private_subnet1_id
  private_subnet2_id   = module.private_subnets.private_subnet2_id
  alb_target_group_arn = module.alb.alb_target_group_arn
  db_host              = module.rds.endpoint
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
}

module "nat_gateway" {
  source = "./modules/nat_gateway"

  public_subnet1_id = module.public_subnets.public_subnet1_id
  public_subnet2_id = module.public_subnets.public_subnet2_id
}

module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet1_id = module.public_subnets.public_subnet1_id
  public_subnet2_id = module.public_subnets.public_subnet2_id
}

module "rds" {
  source = "./modules/rds"

  vpc_id             = module.vpc.vpc_id
  private_subnet1_id = module.private_subnets.private_subnet1_id
  private_subnet2_id = module.private_subnets.private_subnet2_id
  private_sg_id      = module.private_ec2.private_sg_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
}