# ────────────────────────────────────────────────
# EKS Auto Mode 클러스터 생성 선언
# ────────────────────────────────────────────────
resource "aws_eks_cluster" "main" {
  
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