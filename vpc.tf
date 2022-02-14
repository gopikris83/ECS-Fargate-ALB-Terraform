# Create the VPC for shopping app deployment
resource "aws_vpc" "aws-vpc" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.aws-vpc.id
}


# Fetch AZ's in the current region
data "aws_availability_zones" "az" {
}

#Create Private subnet, each in different AZ
resource "aws_subnet" "private_subnet" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.aws-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.az.names[count.index]
  vpc_id            = aws_vpc.aws-vpc.id
}

resource "aws_route" "private-rt" {
  count                  = var.az_count
  route_table_id         = element(aws_route_table.private-route-table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw.*.id, count.index)
}

resource "aws_route_table" "private-route-table" {
  count  = var.az_count
  vpc_id = aws_vpc.aws-vpc.id
}

resource "aws_route_table_association" "private-rt-association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private-route-table.*.id, count.index)
}


#Create Public subnets, each in a different AZ
resource "aws_subnet" "public_subnet" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.aws-vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  vpc_id                  = aws_vpc.aws-vpc.id
  map_public_ip_on_launch = true
}


resource "aws_route" "public-rt" {
  count                  = var.az_count
  route_table_id         = element(aws_route_table.pub-route-table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_internet_gateway.igw.*.id, count.index)
}

resource "aws_route_table" "pub-route-table" {
  count  = var.az_count
  vpc_id = aws_vpc.aws-vpc.id
}

resource "aws_route_table_association" "pub-rt-association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.pub-route-table.*.id, count.index)
}

resource "aws_nat_gateway" "natgw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.tfeip.*.id, count.index)
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_eip" "tfeip" {
  count = var.az_count
  vpc   = true
}