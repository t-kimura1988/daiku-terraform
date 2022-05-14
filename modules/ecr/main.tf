variable "ecs_tasks" {}
variable "env" {

}
resource "aws_ecr_repository" "main" {
  for_each = var.ecs_tasks

  name                 = "${var.env}/${each.value.ecr_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  for_each = var.ecs_tasks

  repository = aws_ecr_repository.main[each.key].name

  policy = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "KEEP last 30 release tagged images",
          "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["release"],
            "countType": "imageCountMoreThan",
            "countNumber": 30
          },
          "action":{
            "type": "expire"
          }
        }
      ]
    }
  EOF

  depends_on = [
    aws_ecr_repository.main
  ]
}