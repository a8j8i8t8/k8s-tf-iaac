# Create the Primary VPC
resource aws_vpc "primary-vpc" {
  cidr_block            = "${var.vpc_generic_cidr_base}/18"
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    "Name"        = "Primary"
    "terraformed" = "yes"
  }
}

# Create an internet gateway
resource aws_internet_gateway "primary-igw" {
  vpc_id = aws_vpc.primary-vpc.id

  tags = {
    "Name"        = "Primary gateway"
    "terraformed" = "yes"
  }
}

# For each AZ listed in vpc_generic_azs, generate a 'public' subnet (max 8)
resource aws_subnet "public-subnet" {
  count             = length(var.vpc_generic_azs)

  vpc_id            = aws_vpc.primary-vpc.id
  cidr_block        = cidrsubnet("${var.vpc_generic_cidr_base}/18", (24-18), count.index)
  availability_zone = element(var.vpc_generic_azs, count.index)

  tags = merge(
    {
      "Name"                            = "public-subnet-${substr(element(var.vpc_generic_azs, count.index), -2, 2)}"
      "terraformed"                     = "yes"
      "SubnetType"                      = "Utility"
      "kubernetes.io/cluster/lg.k8s"    = "owned"
      "kubernetes.io/role/elb"          = "1"
    },
  )
}

# Create an EIP reservation for the NAT gateway
resource aws_eip "natgw" {
  vpc = true
}

# Create a NAT gateway in one of these public subnets
resource aws_nat_gateway "primary-natgw" {
  depends_on      = [aws_internet_gateway.primary-igw]
  allocation_id   = aws_eip.natgw.id
  subnet_id       = element(aws_subnet.public-subnet.*.id, var.vpc_natgw_az_index)

  tags = {
    "Name"        = "Primary NAT gateway"
    "terraformed" = "yes"
  }
}

# For each AZ listed in vpc_generic_azs, generate a 'nat' subnet (max 8)
resource aws_subnet "nat-subnet" {
  count             = length(var.vpc_generic_azs)

  vpc_id            = aws_vpc.primary-vpc.id
  availability_zone = element(var.vpc_generic_azs, count.index)

  # offset by 8, which is the space for public subnets (max 8)
  cidr_block        = cidrsubnet("${var.vpc_generic_cidr_base}/18", (24-18), 8+count.index)

  tags = merge(
    {
      "Name"                              = "nat-subnet-${substr(element(var.vpc_generic_azs, count.index), -2, 2)}"
      "terraformed"                       = "yes"
      "SubnetType"                      = "Private"
      "kubernetes.io/cluster/lg.k8s"    = "owned"
      "kubernetes.io/role/elb"          = "1"
    },
  )
}

# Routing for the public subnets
resource aws_route_table "public-routing-table" {
  vpc_id = aws_vpc.primary-vpc.id

  tags = {
    "Name"          = "public-subnets"
    "terraformed"   = "yes"
  }
}

resource aws_route "public-default-gw" {
  route_table_id          = aws_route_table.public-routing-table.id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.primary-igw.id
}

resource aws_route_table_association "public-rt-assoc" {
  count           = length(var.vpc_generic_azs)

  subnet_id       = element(aws_subnet.public-subnet.*.id, count.index)
  route_table_id  = aws_route_table.public-routing-table.id
}

# Routing for the NAT subnets
resource aws_route_table "nat-routing-table" {
  vpc_id        = aws_vpc.primary-vpc.id

  tags = {
    "Name"        = "nat-subnets"
    "terraformed" = "yes"
  }
}

resource aws_route "nat-default-gw" {
  route_table_id          = aws_route_table.nat-routing-table.id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.primary-natgw.id
}

resource aws_route_table_association "nat-rt-assoc" {
  count           = length(var.vpc_generic_azs)

  subnet_id       = element(aws_subnet.nat-subnet.*.id, count.index)
  route_table_id  = aws_route_table.nat-routing-table.id
}