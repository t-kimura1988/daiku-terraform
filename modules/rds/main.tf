variable "private_subnets" {}
variable "deletion_protection" {}
variable "security_group_id" {}
variable "env" {}
variable "rds_setting" {}

resource "aws_db_parameter_group" "main" {
  name   = "main"
  family = "postgres12"

  parameter {
    name  = "log_min_duration_statement"
    value = "100"
  }
}

resource "aws_db_subnet_group" "main" {
  subnet_ids = var.private_subnets
  name       = "main"
}

resource "aws_db_instance" "main" {
  instance_class             = var.rds_setting.instance_class
  identifier                 = "${var.env}-daiku-db"
  engine                     = "postgres"
  engine_version             = "12.8"
  allocated_storage          = 20
  max_allocated_storage      = 100
  storage_type               = "gp2"
  storage_encrypted          = true
  kms_key_id                 = ""
  username                   = "clusteradmin"
  password                   = "dummyPassword!!"
  multi_az                   = true
  publicly_accessible        = false
  backup_window              = "09:00-09:30"
  backup_retention_period    = 30
  maintenance_window         = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  delete_automated_backups   = var.deletion_protection
  skip_final_snapshot        = false
  port                       = 5432
  apply_immediately          = false
  vpc_security_group_ids     = [var.security_group_id]
  parameter_group_name       = aws_db_parameter_group.main.name
  db_subnet_group_name       = aws_db_subnet_group.main.name

  lifecycle {
    ignore_changes = [password]
  }
}

output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}



