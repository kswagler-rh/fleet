locals {
  name = "fleetdm"
}

resource "random_password" "database_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "database_password_secret" {
  name = "/fleet/database/password/master"
}

resource "aws_secretsmanager_secret_version" "database_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.database_password_secret.id
  secret_string = random_password.database_password.result
}

// if you want to use RDS Serverless option prefer the following commented block
//module "aurora_mysql_serverless" {
//  source  = "terraform-aws-modules/rds-aurora/aws"
//  version = "5.2.0"
//
//  name                   = "${local.name}-mysql"
//  engine                 = "aurora-mysql"
//  engine_mode            = "serverless"
//  storage_encrypted      = true
//  username               = "fleet"
//  password               = random_password.database_password.result
//  create_random_password = false
//  database_name          = "fleet"
//  enable_http_endpoint   = true
//
//  vpc_id                = module.vpc.vpc_id
//  subnets               = module.vpc.database_subnets
//  create_security_group = true
//  allowed_cidr_blocks   = module.vpc.private_subnets_cidr_blocks
//
//  replica_scale_enabled = false
//  replica_count         = 0
//
//  monitoring_interval = 60
//
//  apply_immediately   = true
//  skip_final_snapshot = true
//
//  db_parameter_group_name         = aws_db_parameter_group.example_mysql.id
//  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example_mysql.id
//
//  scaling_configuration = {
//    auto_pause               = true
//    min_capacity             = 2
//    max_capacity             = 16
//    seconds_until_auto_pause = 300
//    timeout_action           = "ForceApplyCapacityChange"
//  }
//}

module "aurora_mysql" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "5.2.0"

  name                  = "${local.name}-mysql-iam"
  engine                = "aurora-mysql"
  engine_version        = "5.7.mysql_aurora.2.10.0"
  instance_type         = "db.t4g.medium"
  instance_type_replica = "db.t4g.medium"

  iam_database_authentication_enabled = true
  storage_encrypted                   = true
  username                            = "fleet"
  password                            = random_password.database_password.result
  create_random_password              = false
  database_name                       = "fleet"
  enable_http_endpoint                = false
  #performance_insights_enabled        = true

  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.database_subnets
  create_security_group = true
  allowed_cidr_blocks   = module.vpc.private_subnets_cidr_blocks

  replica_count         = 1
  replica_scale_enabled = true
  replica_scale_min     = 1
  replica_scale_max     = 3

  monitoring_interval           = 60
  iam_role_name                 = "${local.name}-rds-enhanced-monitoring"
  iam_role_use_name_prefix      = true
  iam_role_description          = "${local.name} RDS enhanced monitoring IAM role"
  iam_role_path                 = "/autoscaling/"
  iam_role_max_session_duration = 7200

  apply_immediately   = true
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.example_mysql.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example_mysql.id

}

resource "aws_db_parameter_group" "example_mysql" {
  name        = "${local.name}-aurora-db-mysql-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.name}-aurora-db-mysql-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "example_mysql" {
  name        = "${local.name}-aurora-mysql-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.name}-aurora-mysql-cluster-parameter-group"
}