# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${local.project}-VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.project}-IGW"
  }
}

# Public Subnets - Public ALB, NAT Gateway
resource "aws_subnet" "public" {
  # 반복데이터 세팅 (cidr)
  for_each                  = local.public_subnets
  vpc_id                    = aws_vpc.main.id
  cidr_block                = each.value
  # 키값이 a면 a에 맞는 값들로 구성, c도 동일함
  availability_zone         = local.azs[each.key]
  map_public_ip_on_launch   = true
  # DE-AI-25-IaC-3tier-V1-PUBLIC-A, DE-AI-25-IaC-3tier-V1-PUBLIC-C
  tags = {
    Name = "${local.project}-PUBLIC-${upper(each.key)}"
    # 커스텀 태그
    Tier = "public"
  }
}

# Private Application Subnets - Web, Was, internal ALB
resource "aws_subnet" "app" {
  for_each                  = local.app_subnets
  vpc_id                    = aws_vpc.main.id
  cidr_block                = each.value
  availability_zone         = local.azs[each.key]
  map_public_ip_on_launch   = false
  tags = {
    Name = "${local.project}-APP-${upper(each.key)}"
    Tier = "application"
  }
}

# Private Db Subnets - RDS
resource "aws_subnet" "db" {
  for_each                  = local.db_subnets
  vpc_id                    = aws_vpc.main.id
  cidr_block                = each.value
  availability_zone         = local.azs[each.key]
  map_public_ip_on_launch   = false
  tags = {
    Name = "${local.project}-DB-${upper(each.key)}"
    Tier = "database"
  }
}

# Public Route Table/association 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${local.project}-PUBLIC-RT"
  }
}
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public  
  subnet_id      = each.value.id # a 존의 서브넷, c 존의 서브넷 -> 반복 구성 연결
  route_table_id = aws_route_table.public.id
}

# Nate Gateway - eip

# Private App Route Table/association  - Web, Was

# Private Db Route Table/association  - RDS

