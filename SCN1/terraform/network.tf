# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "main"
  }
}


# Create 4 subnets (two public & two private) accross 2 availability zone.
resource "aws_subnet" "sub-public-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.0.0/24"
  map_public_ip_on_launch = "true" 
  availability_zone       = "us-east-1a"
  tags = {
    Name = "sub-public-1a"
  }
}

resource "aws_subnet" "sub-public-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "sub-public-1b"
  }
}

resource "aws_subnet" "sub-private-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "sub-private-1a"
  }
}

resource "aws_subnet" "sub-private-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.3.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "sub-private-1b"
  }
}

# Create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw"
  }
}

# Create NAT
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id                # give nat public ip
  subnet_id     = aws_subnet.sub-public-1a.id   # which subnet to attach the nat (public)
  depends_on    = [aws_internet_gateway.igw]    # ig will created first and then the nat
}

# Create EIP
resource "aws_eip" "nat" {
  vpc = true
}


# Create 2 Route Tables
resource "aws_route_table" "route-public" {
  vpc_id = aws_vpc.main.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
  tags = {
    Name = "route-public"
  }
}

resource "aws_route_table" "route-private" {
  vpc_id = aws_vpc.main.id
    route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id 
  }
  tags = {
    Name = "route-private"
  }
}

# Create 4 Route associations
resource "aws_route_table_association" "assoc-public-1a" {
  subnet_id      = aws_subnet.sub-public-1a.id
  route_table_id = aws_route_table.route-public.id
}
resource "aws_route_table_association" "assoc-public-1b" {
  subnet_id      = aws_subnet.sub-public-1b.id
  route_table_id = aws_route_table.route-public.id
}
resource "aws_route_table_association" "assoc-private-1a" {
  subnet_id      = aws_subnet.sub-private-1a.id
  route_table_id = aws_route_table.route-private.id
}
resource "aws_route_table_association" "assoc-private-1b" {
  subnet_id      = aws_subnet.sub-private-1b.id
  route_table_id = aws_route_table.route-private.id
}






