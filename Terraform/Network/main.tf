resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy     = var.instance_tenancy

  tags = {
    "Name" = "${var.name}-${var.environment}-vpc",
    "environment" = "${var.environment}",
    "Region" = "${var.aws_region}",
    "Domain" = "${var.name}",
    "requestor" = "${var.requestor}",
    "customer" = "${var.customer}",
    "tenant" = "${var.tenant}",
    "product" = "${var.product}",
    "manager" = "${var.manager}",
    "owner" = "${var.owner}",
    "purpose" = "${var.purpose}"
  }
}

resource "aws_subnet" "public-subnet" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = format("${var.name}-${var.environment}-public-subnet-%s", count.index),
    "environment" = "${var.environment}",
    "Region" = "${var.aws_region}",
    "Domain" = "${var.name}",
    "requestor" = "${var.requestor}",
    "customer" = "${var.customer}",
    "tenant" = "${var.tenant}",
    "product" = "${var.product}",
    "manager" = "${var.manager}",
    "owner" = "${var.owner}",
    "purpose" = "${var.purpose}"
  }
}

resource "aws_subnet" "private-subnet" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = format("${var.name}-${var.environment}-private-subnet-%s", count.index),
    "environment" = "${var.environment}",
    "Region" = "${var.aws_region}",
    "Domain" = "${var.name}",
    "requestor" = "${var.requestor}",
    "customer" = "${var.customer}",
    "tenant" = "${var.tenant}",
    "product" = "${var.product}",
    "manager" = "${var.manager}",
    "owner" = "${var.owner}",
    "purpose" = "${var.purpose}"
  }
}

resource "aws_internet_gateway" "default-igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.name}-${var.environment}-igw"
    "environment" = "${var.environment}",
    "Region" = "${var.aws_region}",
    "Domain" = "${var.name}",
    "requestor" = "${var.requestor}",
    "customer" = "${var.customer}",
    "tenant" = "${var.tenant}",
    "product" = "${var.product}",
    "manager" = "${var.manager}",
    "owner" = "${var.owner}",
    "purpose" = "${var.purpose}"
  }
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default-igw.id
  }

  tags = {
    Name = "${var.name}-${var.environment}-rt",
    "environment" = "${var.environment}",
    "Region" = "${var.aws_region}",
    "Domain" = "${var.name}",
    "requestor" = "${var.requestor}",
    "customer" = "${var.customer}",
    "tenant" = "${var.tenant}",
    "product" = "${var.product}",
    "manager" = "${var.manager}",
    "owner" = "${var.owner}",
    "purpose" = "${var.purpose}"
  }
}

resource "aws_route_table_association" "rta-public-subnet" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.default.id
}

resource "aws_eip" "nat-gateway-ip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-gateway-ip.id
  subnet_id     = aws_subnet.public-subnet[0].id
  tags = {
    "Name" = "${var.name}-${var.environment}-Nategateway",
    "environment" = "${var.environment}",
    "Region" = "${var.aws_region}",
    "Domain" = "${var.name}",
    "requestor" = "${var.requestor}",
    "customer" = "${var.customer}",
    "tenant" = "${var.tenant}",
    "product" = "${var.product}",
    "manager" = "${var.manager}",
    "owner" = "${var.owner}",
    "purpose" = "${var.purpose}"
  }
}

resource "aws_route_table" "nat-gateway" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    "Name" = "${var.name}-${var.environment}-nrt"
    "environment" = "${var.environment}",
    "Region" = "${var.aws_region}",
    "Domain" = "${var.name}",
    "requestor" = "${var.requestor}",
    "customer" = "${var.customer}",
    "tenant" = "${var.tenant}",
    "product" = "${var.product}",
    "manager" = "${var.manager}",
    "owner" = "${var.owner}",
    "purpose" = "${var.purpose}"
  }
}

resource "aws_route_table_association" "nat-gateway" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.nat-gateway.id
}
