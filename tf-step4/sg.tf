############################################
# Security Group Rules (반복관련)
############################################
locals {
  security_groups = {
    web = {
        ingress = {
            ssh   = {
                port = 22,              # 포트 값 표현
                cidr = ["0.0.0.0/0"]    # n개 나올수 있는 허가된 IP값 나열(리스트)
            }
            http  = {
                port = 80,
                cidr = ["0.0.0.0/0"]
            }            
        }
    }
    was = {
        ingress = {
            ssh   = {
                port = 22,              # 포트 값 표현
                cidr = ["0.0.0.0/0"]    # n개 나올수 있는 허가된 IP값 나열(리스트)
            }
            tcp  = {
                port = 8000,
                cidr = ["0.0.0.0/0"]
            }            
        }
    }
    db  = {
        ingress = {
            ssh   = {
                port = 22,              # 포트 값 표현
                cidr = ["0.0.0.0/0"]    # n개 나올수 있는 허가된 IP값 나열(리스트)
            }
            tcp  = {
                port = 3306,
                cidr = ["0.0.0.0/0"]
            }            
        }
    }
  }
}