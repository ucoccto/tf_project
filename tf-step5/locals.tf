##########################################
# 전체 구성상 반복적으로 배치되는 변수값들 구성
##########################################
locals {
    # 프로젝트명 (반복은 아니지만 필수도 아님) -> 상수(고정값) 관점
    project = "DE-AI-25-IaC-3tier-V1"
    # 리소스에 적용된 공용 태그 -> 커스텀 구성 태그들을 리소스에 공통 배치하기 위함
    common_tags = {
        Project = locals.project
        Environment = var.environment
        ManageBy = "Terraform"
    }
    # 서울 리전 2개 가용영역(a, c) 사용 (본인 속한 리전 이름으로 변경)
    azs = {
        a = "ap-northeast-2a"
        c = "ap-northeast-2c"
    }
    # ALB -> 2개 가용영역(a, c)에 서브넷 각각 1개(퍼블릭) -> cidr 설정
    public_subnets = {
        a = "10.0.1.0/24"
        c = "10.0.2.0/24"
    }
    # WEB/WAS ASG -> cidr
    app_subnets = {
        a = "10.0.11.0/24"
        c = "10.0.12.0/24"
    }
    # RDS -> cidr
    db_subnets = {
        a = "10.0.21.0/24"
        c = "10.0.22.0/24"
    }
}