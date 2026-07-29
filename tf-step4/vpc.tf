# 특정 기업/개인/단체등 전용 VPC 생성 선언
resource "aws_vpc" "DE-AI-25-company" {
  # CIDR(Classless Inter-Domain Routing) 규칙 지정 65536개 IP를 구성할수 있다. 10.0.0.0/16
  # CIDR 블록 크기는 /16에서 /28 => AWS 제약사항
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "DE-AI-25-company-vpc"
  }
}
# 서브넷 (public)
resource "aws_subnet" "public" {
  # 암묵적 의존성 -> 서브넷 구성을위해서는 반드시 vpc가 먼저 생성되어야 함
  vpc_id = aws_vpc.DE-AI-25-company.id
  # CIDR 가용영역 설정, VPC보다 작게, 24(3자리 고정) -> 256개 가용
  cidr_block = "10.0.1.0/24"
  # 리전마다 가용영역이 a,b,c,d  or a,b,c 제한 => 데이터센터 동수
  availability_zone = "ap-northeast-2a"
  # map 타입으로 관리 public_ip
  map_public_ip_on_launch = true
  # 개인 구분용도 일단 활용
  tags = {
    Name = "DE-AI-25-public-subnet"
  }
}
# 현재까지는 퍼블릭 IP 활성화 차단된 상태임

# 인터넷 게이트웨이
resource "aws_internet_gateway" "company" {
  vpc_id = aws_vpc.DE-AI-25-company.id
  tags = {
    Name = "DE-AI-25-company-igw"
  }
}

# 라우트 테이블
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.DE-AI-25-company.id
  # 모든 IP 대역 (편의상) => IGW 전달(연결)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.company.id
  }
  tags = {
    Name = "DE-AI-25-company-public-rt"
  }
}

# 최종연결 (공개용 서브넷 -> 공개용 라우트테이블)
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# private 서브넷 구성
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.DE-AI-25-company.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"  
  tags = {
    Name = "DE-AI-25-private-subnet"
  }
}

# 라우트 테이블
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.DE-AI-25-company.id  
  tags = {
    Name = "DE-AI-25-company-private-rt"
  }
}

# 최종연결 (프라이빗 서브넷 -> 프라이빗전용 라우트테이블)
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}