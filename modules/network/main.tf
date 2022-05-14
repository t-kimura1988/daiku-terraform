variable "vpc_cidr" {}
variable "protected_subnets" {}
variable "private_subnets" {}
variable "public_subnets" {
}
variable "env" {}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-ig"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.ig.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.env}-${each.value.name}"
  }
}

resource "aws_route_table_association" "public" {
  for_each = var.public_subnets

  subnet_id      = aws_subnet.public[each.value.name].id
  route_table_id = aws_route_table.public.id

}

resource "aws_subnet" "protected" {
  for_each = var.protected_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.env}-${each.value.name}"
  }
}

resource "aws_eip" "nat_gateway" {
  for_each = var.public_subnets
  vpc      = true
  depends_on = [
    aws_internet_gateway.ig
  ]
  tags = {
    Name = each.value.nat_gateway
  }
}

resource "aws_nat_gateway" "main" {
  for_each      = var.public_subnets
  allocation_id = aws_eip.nat_gateway[each.value.name].id

  subnet_id = aws_subnet.public[each.value.name].id

  depends_on = [
    aws_internet_gateway.ig
  ]
}

output "aws_nat_gateway" {
  value = aws_nat_gateway.main
}

resource "aws_route_table" "protected" {
  for_each = var.protected_subnets
  vpc_id   = aws_vpc.main.id
}

resource "aws_route" "protected" {

  for_each = aws_route_table.protected

  route_table_id = each.value.id

  nat_gateway_id         = aws_nat_gateway.main[replace(each.key, "protected", "public")].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "protected" {
  for_each = aws_subnet.protected

  subnet_id      = each.value.id
  route_table_id = aws_route_table.protected[each.key].id
}


resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.env}-${each.value.name}"
  }
}

resource "aws_subnet" "private-ssm" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.213.30.0/24"
  availability_zone = "ap-northeast-1a"

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.env}-private-ssm"
  }
}

resource "aws_route_table" "private" {
  for_each = var.private_subnets
  vpc_id   = aws_vpc.main.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for i in aws_subnet.public : i.id]
}

output "protected_subnet_ids" {
  value = [for i in aws_subnet.protected : i.id]
}


output "private_subnet_ids" {
  value = [for i in aws_subnet.private : i.id]
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "private_subnet_ssm_id" {
  value = aws_subnet.private-ssm.id
}

output "route_table_protected_ids" {
  value = [for i in aws_route_table.protected : i.id]
}