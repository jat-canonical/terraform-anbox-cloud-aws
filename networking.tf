resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  map_public_ip_on_launch = true
  availability_zone       = local.az1
  tags = {
    Name = "${var.environment_name} public subnet 1 (${local.az1})"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = local.az1
  tags = {
    Name = "${var.environment_name} private subnet 1 (${local.az1})"
  }
}

resource "aws_eip" "public_nat_1" {
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "public_1" {
  allocation_id = aws_eip.public_nat_1.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.environment_name} public routes"
  }
}

resource "aws_route_table_association" "public_subnet_1" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1.id
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_1.id
  }
  tags = {
    Name = "${var.environment_name} private routes (${local.az1})"
  }
}

resource "aws_route_table_association" "private_subnet_1" {
  route_table_id = aws_route_table.private_1.id
  subnet_id      = aws_subnet.private_1.id
}

resource "aws_route53_zone" "private" {
  name = var.private_domain_name
  vpc {
    vpc_id = aws_vpc.main.id
  }
}
