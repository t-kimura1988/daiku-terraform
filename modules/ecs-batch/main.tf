variable "env" {}
variable "ecs_cluster_arn" {}

variable "ecs_tasks" {

}

data "template_file" "task" {

  template = file("./modules/ecs-batch/container-definitions-daiku-batch-${var.env}.json")
  vars = {
    image = "test:latest"
  }
}

resource "aws_ecs_task_definition" "batch_task" {
  for_each                 = var.ecs_tasks
  family                   = "${var.env}-${each.value.family}"
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.task.rendered
}
