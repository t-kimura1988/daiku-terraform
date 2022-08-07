# module "s3_log" {
#   source      = "./modules/s3"
#   bucket_name = "${var.ENV}-${local.dev.s3_alb_bucket_name}"
# }

# module "network" {
#   source            = "./modules/network"
#   vpc_cidr          = local.variable.vpc_cidr
#   protected_subnets = local.variable.protected_subnets
#   public_subnets    = local.variable.public_subnets
#   env               = var.ENV
#   private_subnets   = local.variable.private_subnets
# }

# module "http_sg" {
#   source      = "./modules/security_group"
#   name        = "${var.ENV}-http-sg"
#   vpc_id      = module.network.vpc_id
#   port        = 80
#   cidr_blocks = ["0.0.0.0/0"]
# }

# module "https_sg" {
#   source      = "./modules/security_group"
#   name        = "${var.ENV}-https-sg"
#   vpc_id      = module.network.vpc_id
#   port        = 443
#   cidr_blocks = ["0.0.0.0/0"]
# }

# module "daiku_app_sg" {
#   source      = "./modules/security_group"
#   name        = "${var.ENV}-daiku_app_sg"
#   vpc_id      = module.network.vpc_id
#   port        = 8080
#   cidr_blocks = ["0.0.0.0/0"]
# }

# module "postgres_sg" {
#   source      = "./modules/security_group"
#   name        = "${var.ENV}-postgres_sg"
#   vpc_id      = module.network.vpc_id
#   port        = 5432
#   cidr_blocks = [module.network.vpc_cidr_block]
# }

# module "vpc_endpoint_sg" {
#   source      = "./modules/security_group"
#   name        = "${var.ENV}-vpc_endpoint_sg"
#   vpc_id      = module.network.vpc_id
#   port        = 443
#   cidr_blocks = [module.network.vpc_cidr_block]

# }

# module "daiku_app_lb" {
#   source     = "./modules/load_balancer"
#   subnet_ids = module.network.public_subnet_ids
#   security_group_ids = [
#     module.http_sg.security_group_id,
#     module.https_sg.security_group_id
#   ]
#   bucket_id                  = module.s3_log.bucket_id
#   enable_deletion_protection = local.variable.enable_deletion_protection
#   vpc_id                     = module.network.vpc_id
#   app_lb                     = local.variable.ecs_app_task
#   route53_zone_name          = local.variable.route53_zone_name
# }

# resource "aws_ecs_cluster" "main" {
#   name = "${var.ENV}-daiku"
# }

# module "ecs_daiku_app" {
#   source                  = "./modules/ecs-app"
#   env                     = var.ENV
#   ecs_tasks               = local.variable.ecs_app_task
#   ecs_cluster_arn         = aws_ecs_cluster.main.arn
#   protected_subnets       = module.network.protected_subnet_ids
#   security_group_ids      = [module.daiku_app_sg.security_group_id]
#   aws_lb_target_group_arn = module.daiku_app_lb.target_group_arn
#   alb_depends_on          = module.daiku_app_lb.alb_listener_depends_on
# }

# module "ecr_daiku_app" {
#   source    = "./modules/ecr"
#   env       = var.ENV
#   ecs_tasks = local.variable.ecs_app_task
# }

# module "ecs_daiku_batch" {
#   source          = "./modules/ecs-batch"
#   env             = var.ENV
#   ecs_tasks       = local.variable.ecs_batch_task
#   ecs_cluster_arn = aws_ecs_cluster.main.arn
# }

# module "ecr_daiku_batch" {
#   source    = "./modules/ecr"
#   env       = var.ENV
#   ecs_tasks = local.variable.ecs_batch_task
# }

# module "rds" {
#   source              = "./modules/rds"
#   private_subnets     = module.network.private_subnet_ids
#   deletion_protection = local.variable.enable_deletion_protection
#   security_group_id   = module.postgres_sg.security_group_id
#   env                 = var.ENV

#   rds_setting = local.variable.rds_setting
# }

# module "ssm_parameter" {
#   source            = "./modules/ssm_parameter"
#   string_parameters = local.variable.ssm_string_parameter
#   secure_parameters = local.variable.ssm_secure_string_parameter
#   env               = var.ENV
# }

# module "ssm_manager" {
#   source                = "./modules/ssm"
#   ssm_private_subnet_id = module.network.private_subnet_ssm_id
#   vpc_id                = module.network.vpc_id
#   aws_nat_gateway       = module.network.aws_nat_gateway
#   env                   = var.ENV
# }

# module "vpc_endpoint" {
#   source                    = "./modules/vpc-endpoint"
#   route_table_protected_ids = module.network.route_table_protected_ids
#   subnet_id                 = module.network.private_subnet_ssm_id
#   vpc_endpoint_sg           = module.vpc_endpoint_sg.security_group_id
#   vpc_id                    = module.network.vpc_id
# }