variable "env" {}
variable "ecs_cluster_arn" {}
variable "security_group_ids" {}
variable "protected_subnets" {}

variable "ecs_tasks" {

}

data "aws_caller_identity" "current" {}

data "template_file" "task" {
  for_each = var.ecs_tasks
  template = file("./modules/ecs-batch/container-definitions-daiku-batch-${var.env}.json")
  vars = {
    image       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.env}/daiku-batch:latest"
    awslogGroup = "${var.env}/ecs/daiku/${each.value.family}"
    env         = var.env
  }
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {

  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

module "ecs_task_execution_role" {
  source     = "../role"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

resource "aws_ecs_task_definition" "app_task" {
  for_each                 = var.ecs_tasks
  family                   = "${var.env}-${each.value.family}"
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.task[each.key].rendered
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

resource "aws_ecs_service" "main" {
  for_each                          = var.ecs_tasks
  name                              = "${var.env}-${each.value.ecs_service_name}"
  cluster                           = var.ecs_cluster_arn
  task_definition                   = aws_ecs_task_definition.app_task[each.key].arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  network_configuration {
    security_groups  = var.security_group_ids
    assign_public_ip = false
    subnets          = var.protected_subnets
  }
  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [var.security_group_ids, aws_ecs_task_definition.app_task]
}

resource "aws_cloudwatch_log_group" "for_ecs" {
  for_each          = var.ecs_tasks
  name              = "${var.env}/ecs/daiku/${each.value.family}"
  retention_in_days = each.value.retention_in_days
}
