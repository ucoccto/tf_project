############################################
# Security Group Rules (반복관련)
############################################
locals {
  security_groups = {
    web = {
      ingress = {
        ssh = {
          port = 22,           # 포트 값 표현
          cidr = ["0.0.0.0/0"] # n개 나올수 있는 허가된 IP값 나열(리스트)
        }
        http = {
          port = 80,
          cidr = ["0.0.0.0/0"]
        }
      }
    }
    was = {
      ingress = {
        ssh = {
          port = 22,           # 포트 값 표현
          cidr = ["0.0.0.0/0"] # n개 나올수 있는 허가된 IP값 나열(리스트)
        }
        # 오직 web -> was로만 접근해야함. 취지 벗어남 (다른 방식으로 구성)
        # tcp  = {
        #     port = 8000,
        #     cidr = ["0.0.0.0/0"]
        # }            
      }
    }
    db = {
      ingress = {
        ssh = {
          port = 22,           # 포트 값 표현
          cidr = ["0.0.0.0/0"] # n개 나올수 있는 허가된 IP값 나열(리스트)
        }
        # 오직 was -> db로만 접근해야함. 취지 벗어남 (다른 방식으로 구성)
        # tcp  = {
        #     port = 3306,
        #     cidr = ["0.0.0.0/0"]
        # }            
      }
    }
  }
}

############################################
# Security Groups 생성 선언
############################################
resource "aws_security_group" "sg" {
  # 반복 데이터로 구성한 locals 주입(세팅) -> web, was, db 총 3개의 맴버를 가짐
  for_each = local.security_groups
  # for_each에 Map 타입으로 주입 => each.key, each.value 형태로 반복적, 순서대로 획득 
  # 이름 => DE-AI-25-web-sg-해시값, DE-AI-25-was-sg-해시값, DE-AI-25-db-sg-해시값
  name_prefix = "DE-AI-25-${each.key}-sg-"
  description = "${upper(each.key)} Security Group"

  # VPC 지정
  vpc_id = aws_vpc.DE-AI-25-company.id

  # ingress 동적 생성 => 블록 반복 구성 => dynamic ingress
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.port # 80, 22
      to_port     = ingress.value.port # 80, 22
      protocol    = "tcp"              # 고정값
      cidr_blocks = ingress.value.cidr # ["0.0.0.0/0"]
    }
  }

  # 아웃바운드 고정
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# Web -> Was 룰 적용, 포트 8000 오픈, 룰생성 선언
############################################
resource "aws_security_group_rule" "web-to-was" {
  type = "ingress"
  # 소스(web) 보안 그룸
  source_security_group_id = aws_security_group.sg["web"].id
  # 타겟(was) 보안 그룹
  security_group_id = aws_security_group.sg["was"].id
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
}

############################################
# Was -> Db 룰 적용, 포트 3306 오픈, 룰생성 선언
############################################
resource "aws_security_group_rule" "was-to-to" {
  type = "ingress"
  # 소스(Was) 보안 그룸
  source_security_group_id = aws_security_group.sg["was"].id
  # 타겟(Db) 보안 그룹
  security_group_id = aws_security_group.sg["db"].id
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
}