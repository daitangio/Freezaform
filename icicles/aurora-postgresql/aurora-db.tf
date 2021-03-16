
// GG Adapted from
// https://github.com/terraform-aws-modules/terraform-aws-rds-aurora/tree/v3.10.0/examples/postgresql


locals {
  name   = "tic-tac-crok" 
  tags = {
    
    Environment = "poc-${local.magi_tag}"    
  }
}

################################################################################
# Supporting Resources
################################################################################


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"

  name = local.name
  cidr = "10.99.0.0/18"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]

  tags = local.tags

  // Disable if publicly_accessible=false
  // see https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest  
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  
}

################################################################################
# RDS Aurora Module
################################################################################

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  // source = "../../"
  version ="3.10.0"
  name                  = local.name
  engine                = "aurora-postgresql"
  engine_version        = "12.4"
  
  instance_type         = "db.r5.large"
  instance_type_replica = "db.t3.medium"

  //instance_type         = "db.r5.large"
  //instance_type_replica = "db.t3.medium"

  vpc_id                = module.vpc.vpc_id
  db_subnet_group_name  = module.vpc.database_subnet_group_name
  create_security_group = true
  allowed_cidr_blocks   = module.vpc.private_subnets_cidr_blocks

  replica_count                       = 1
  
  iam_database_authentication_enabled = true
  username                            = "crok"
  password                            = var.root_password
  create_random_password              = false
  database_name="crok"

  apply_immediately   = true
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.example.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example.id
  enabled_cloudwatch_logs_exports = ["postgresql"]
  // BUG: Default rds-ca-2019 is not found on milan
  // ${local.region}
  //ca_cert_identifier="rds-ca-2019-eu-south-1"
  ca_cert_identifier="rds-ca-2019-${local.region}"

  publicly_accessible="true"
  tags = local.tags
}

resource "aws_db_parameter_group" "example" {
  name        = "${local.name}-aurora-db-postgres12-parameter-group"
  family      = "aurora-postgresql12"
  description = "${local.name}-aurora-db-postgres12-parameter-group"
  tags        = local.tags
}

resource "aws_rds_cluster_parameter_group" "example" {
  name        = "${local.name}-aurora-postgres12-cluster-parameter-group"
  family      = "aurora-postgresql12"
  description = "${local.name}-aurora-postgres12-cluster-parameter-group"
  tags        = local.tags
}