variable "env" {}
variable "ecs_cluster_arn" {}
variable "security_group_ids" {}
variable "protected_subnets" {}
variable "aws_lb_target_group_arn" {}

variable "ecs_tasks" {

}

variable "alb_depends_on" {}
variable "iam_role_arn" {}

data "aws_caller_identity" "current" {}

data "template_file" "task" {
  for_each = var.ecs_tasks
  template = file("./modules/ecs-app/container-definitions-daiku-app-${var.env}.json")
  vars = {
    image       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.env}/daiku-app:latest"
    awslogGroup = "${var.env}/ecs/daiku/${each.value.family}"
    env         = var.env
  }
}

resource "aws_ecs_task_definition" "app_task" {
  for_each                 = var.ecs_tasks
  family                   = "${var.env}-${each.value.family}"
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.task[each.key].rendered
  execution_role_arn       = var.iam_role_arn
}

resource "aws_ecs_service" "main" {
  for_each                          = var.ecs_tasks
  name                              = "${var.env}-${each.value.ecs_service_name}"
  cluster                           = var.ecs_cluster_arn
  task_definition                   = aws_ecs_task_definition.app_task[each.key].arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 3600
  network_configuration {
    security_groups  = var.security_group_ids
    assign_public_ip = false
    subnets          = var.protected_subnets
  }
  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn[each.key].arn
    container_name   = "main"
    container_port   = 8080
  }
  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [var.alb_depends_on, var.security_group_ids, aws_ecs_task_definition.app_task]
}

resource "aws_cloudwatch_log_group" "for_ecs" {
  for_each          = var.ecs_tasks
  name              = "${var.env}/ecs/daiku/${each.value.family}"
  retention_in_days = each.value.retention_in_days
}