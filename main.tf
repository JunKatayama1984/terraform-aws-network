provider "aws" {
  region  = var.region
  version = "~> 3.37"
}

resource "aws_vpc" "this" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block = var.CIDR
}

resource "aws_subnet" "this" {
  count = length(var.networks)
  vpc_id     = aws_vpc.this.id
  cidr_block = var.networks[count.index]
}

resource "aws_internet_gateway" "igw" {
  count = var.igw ? 1 : 0
  vpc_id   = aws_vpc.this.id
}

resource "aws_route_table" "internet_route" {
  count = var.igw ? 1 : 0
  vpc_id   = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Internet-Access"
  }
}

resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  count = var.igw ? 1 : 0
  vpc_id   = aws_vpc.this.id
  route_table_id = aws_route_table.internet_route[0].id
}