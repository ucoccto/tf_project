# ────────────────────────────────────────────────
# EKS Auto Mode 클러스터 생성 선언
# ────────────────────────────────────────────────

# 쿠버네티스 컨트로 플레인 생성, EKS Auto Mode 기능 활성화 
resource "aws_eks_cluster" "main" {
    # eks 클러스터 이름
    name = local.cluster_name

    # 버전 (1.35)
    version = var.kubernetes_version

    # EKS Control plane이 AWS 리소스 관리할대 IAM role
    role_arn = aws_iam_role.eks_cluster.arn

    # Auto Mode(자동 직접 관리) 이므로 컨트롤 플레인에 필요한 기능등 별도로 addon 하지 않음
    bootstrap_self_managed_addons = false

    # EKS 접근 권한 관리 방식
    access_config {
      
    }

    # EKS Auto Mode Compute 설정
    compute_config {
      
    }

    # 쿠버네티스 네트워크 설정
    kubernetes_network_config {
      
    }

    # 쿠버네티스 영구 스토리지 설정
    storage_config {
      
    }

    # EKS가 사용하는 VPC, API endpoing  설정
    vpc_config {
      
    }

    # 컨트롤 플레인의 로그
    enabled_cluster_log_types = [

    ]

    # 태그
    tags = {
      Name = local.cluster_name
    }

    # 의존성
    depends_on = [ 

    ]
}


# ────────────────────────────────────────────────
# Metrics Server addon 구성 (CPU 사용량등 => pod증감등 관련 지표 )
# ────────────────────────────────────────────────
# resource "aws_eks_addon" "metrics_server" {
  
# }


# ────────────────────────────────────────────────
# IAM Role 부분 추가 등록등 처리
# ────────────────────────────────────────────────
# resource "aws_eks_access_entry" "admin" {
  
# }
# resource "aws_eks_access_policy_association" "admin" {
  
# }