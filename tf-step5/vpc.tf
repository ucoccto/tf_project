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

# Nat Gateway - eip
resource "aws_eip" "nat" {
  for_each = local.azs # a존, c존에 각각 IP 할당
  domain = "vpc"
  tags = {
    Name = "${local.project}-NAT-EIP-${upper(each.key)}" # A, C
  }
}
resource "aws_nat_gateway" "main" {
  for_each = local.azs 
  allocation_id = aws_eip.nat[each.key].id  # ..nat['A'].., ..nat['C']..
  # A존의 퍼블릭 서브넷, C존의 퍼블릭 서브넷 각각 연결
  subnet_id = aws_subnet.public[each.key].id 
  tags = {
    Name = "${local.project}-NAT-${upper(each.key)}"
  }
  depends_on = [
    aws_internet_gateway.main
  ]
}

# Private App Route Table/association
resource "aws_route_table" "app" {
  for_each = local.azs
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main[each.key].id
  }
  tags = {
    Name = "${local.project}-APP-RT"
  }
}
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.app[each.key].id
}
# Private Db Route Table/association

