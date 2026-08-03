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