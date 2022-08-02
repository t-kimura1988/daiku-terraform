variable "vpc_id" {}
variable "route_table_protected_ids" {
  type = list(string)
}
variable "vpc_endpoint_sg" {
}
variable "subnet_id" {
}


data "aws_iam_policy_document" "vpc_endpoint" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_vpc_endpoint" "s3" {
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_protected_ids
  tags = {
    Name = "protected-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  private_dns_enabled = true
  vpc_id              = var.vpc_id
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.vpc_endpoint_sg]
  subnet_ids = [
    var.subnet_id
  ]

  tags = {
    Name = "ecr-dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  private_dns_enabled = true
  vpc_id              = var.vpc_id
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.vpc_endpoint_sg]
  subnet_ids = [
    var.subnet_id
  ]

  tags = {
    Name = "ecr-api-endpoint"
  }
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-northeast-1.ssm"
  policy            = data.aws_iam_policy_document.vpc_endpoint.json
  subnet_ids = [
    var.subnet_id
  ]
  private_dns_enabled = true
  security_group_ids  = [var.vpc_endpoint_sg]

  tags = {
    Name = "vpc-ssm"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-northeast-1.ssmmessages"
  policy            = data.aws_iam_policy_document.vpc_endpoint.json
  subnet_ids = [
    var.subnet_id
  ]
  private_dns_enabled = true
  security_group_ids  = [var.vpc_endpoint_sg]

  tags = {
    Name = "vpc-ssm-messages"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-northeast-1.ec2messages"
  policy            = data.aws_iam_policy_document.vpc_endpoint.json
  subnet_ids = [
    var.subnet_id
  ]
  private_dns_enabled = true
  security_group_ids  = [var.vpc_endpoint_sg]

  tags = {
    Name = "vpc-ec2-messages"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    var.subnet_id
  ]
  security_group_ids = [var.vpc_endpoint_sg]

  tags = {
    Name = "vpc-logs"
  }
}
