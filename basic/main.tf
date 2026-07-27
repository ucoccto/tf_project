# 1. 현재 리전의 VPC 서비스 중 default 정보 조회 ( data )
#    - 현재 리전의 VPC 서비스 중 default 정보 조회 하라 -> data.aws_vpc.default.id 참조
data "aws_vpc" "default" {
    default = true
}

# 2. 기본 VPC의 서비스 정보 조회 하라 (data)
#    n개의 서브넷이 존재하므로 이를 values에 담아라
data "aws_subnets" "default" {
    filter {
      name = "vpc-id"
      values = [data.aws_vpc.default.id]
    }
}

# 3. 보안그룹 생성 선언 - EC2 진입 하는데 인바운드 IP/포트, 아웃바운드 IP/포트 설정 => 접근 제한!!
resource "aws_security_group" "DE-AI-25-IaC-TF-GROUP" {
    # 메타 정보
    name = "terraform-25-sg"
    description = "de-ai-25 계정이 생성한 보안 그룹"
    # 보안 그룹은 VPC에 종속되어서 구성됨
    # id => 리소스명-해시값(중복x, 고유값)
    vpc_id = data.aws_vpc.default.id
    # 인바운드   (외부 트레픽이 내부로 들어옴) -> 일단 필요한 만큼 생성 -> 추후 반복문?등 문법효율적 활용을 통해 구성
    ingress = {
        
    }
    ingress = {

    }
    # 아웃바운드 (내부 트레픽이 외부로 나감)
    egress = {

    }
}