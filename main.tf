resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "A4LVPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "A4L-IGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "A4L Public Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

# resource "aws_route_table_association" "app_private_subnet_asso" {
#   count          = length(var.app_private_subnet_cidrs)
#   subnet_id      = element(aws_subnet.app_private_subnets[*].id, count.index)
#   route_table_id = aws_route_table.app_private_rt.id
# }

# resource "aws_route_table_association" "db_private_subnet_asso" {
#   count          = length(var.db_private_subnet_cidrs)
#   subnet_id      = element(aws_subnet.db_private_subnets[*].id, count.index)
#   route_table_id = aws_route_table.db_private_rt.id
# }

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "app_private_subnets" {
  count             = length(var.app_private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.app_private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "App Private Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "db_private_subnets" {
  count             = length(var.db_private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.db_private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "DB Private Subnet ${count.index + 1}"
  }
}

