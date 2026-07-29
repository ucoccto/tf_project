# 반복된 내용 locals 구성

# ami 조회
data "aws_ami" "amazon_linux" {
  # 최신 설정
  most_recent = true
  # 소유자
  owners = ["amazon"]
  # 필터링
  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
}

# aws_instace 생성 선언 -> 반복

# 오직 web용 ec2만 EIP 생성 선언 
resource "aws_eip" "DE-AI-25-IaC-TF-EIP" {
  # EC2 인스턴스 -> web 용 ec2
  instance = aws_instance.   .id
  # 네트워크
  domain = "vpc"
}