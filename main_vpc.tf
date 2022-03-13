locals {
  environment-name = "my"
}

# VPC
resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default" // no dedicated hardware
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.environment-name}-vpc"
  }
}

# SUBNET
resource "aws_subnet" "public-subnet" {
  count                   = var.install-in-number-of-availability-zone
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.main-azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.environment-name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private-subnet" {
  count             = var.install-in-number-of-availability-zone
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.main-azs.names[count.index]

  tags = {
    Name = "${local.environment-name}-private-subnet-${count.index + 1}"
  }
}

# ROUTE-TABLE
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw[0].id
  }

  tags = {
    Name = "${local.environment-name}-private-route-table"
  }
}

# Associate subnet with Route Table
resource "aws_route_table_association" "private-subnet-association" {
  count          = var.install-in-number-of-availability-zone
  subnet_id      = aws_subnet.private-subnet.*.id[count.index]
  route_table_id = aws_route_table.private-route-table.id
  depends_on     = [aws_route_table.private-route-table, aws_subnet.private-subnet]
}

# Private Route Table Assiciation
resource "aws_default_route_table" "public-route-table" {
  default_route_table_id = aws_vpc.main-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }

  tags = {
    Name = "${local.environment-name}-public-route-table"
  }
}
# Associate subnet with Route Table
resource "aws_route_table_association" "public-subnet-association" {
  count          = var.install-in-number-of-availability-zone
  subnet_id      = aws_subnet.public-subnet.*.id[count.index]
  route_table_id = aws_default_route_table.public-route-table.id
  depends_on     = [aws_default_route_table.public-route-table, aws_subnet.public-subnet]
}

# IGW
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${local.environment-name}-internet-gateway"
  }
}

# EIP
resource "aws_eip" "nate-eip" {
  count = var.install-in-number-of-availability-zone
  vpc   = true
}

# NAT Gateway
resource "aws_nat_gateway" "nat-gw" {
  count             = var.install-in-number-of-availability-zone
  allocation_id     = aws_eip.nate-eip.*.id[count.index]
  subnet_id         = aws_subnet.public-subnet.*.id[count.index]
  connectivity_type = "public"

  tags = {
    Name = "${local.environment-name}-NAT-gateway-${count.index + 1}"
  }
}

# SECURITY-GROUP-public
resource "aws_security_group" "public-security-group" {
  vpc_id = aws_vpc.main-vpc.id
  name   = "${local.environment-name}-public-security-group"

  # ingress {
  #   description = "from Internet"
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  ingress {
    description = "Https/TLS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "out to Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.environment-name}-public-security-group"
  }
}

# SECURITY-GROUP-private
resource "aws_security_group" "private-security-group" {
  vpc_id = aws_vpc.main-vpc.id
  name   = "${local.environment-name}-private-security-group"
  ingress {
    security_groups = [aws_security_group.public-security-group.id]
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
  }
  egress {
    description = "out to Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.environment-name}-private-security-group"
  }
}
