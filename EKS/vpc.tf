# Data Source to Get Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    "Name"                       = "${var.cluster_name}-vpc",
    "kubernetes.io/role/elb"     = "1",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    "Name" = "${var.cluster_name}-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = var.public_subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(var.tags, {
    "Name"                       = "${var.cluster_name}-public-subnet-${count.index}",
    "kubernetes.io/role/elb"     = "1",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + var.public_subnet_count)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(var.tags, {
    "Name"                       = "${var.cluster_name}-private-subnet-${count.index}",
    "kubernetes.io/role/internal-elb" = "1",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# NAT Gateway EIP
resource "aws_eip" "nat" {
  count  = var.private_subnet_count
  domain = "vpc"

  tags = merge(var.tags, {
    "Name" = "${var.cluster_name}-eip-${count.index}"
  })
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  count         = var.private_subnet_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    "Name" = "${var.cluster_name}-nat-${count.index}"
  })
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    "Name" = "${var.cluster_name}-public-rt"
  })
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[0].id
  }

  tags = merge(var.tags, {
    "Name" = "${var.cluster_name}-private-rt"
  })
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table Associations for Private Subnets
resource "aws_route_table_association" "private" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
