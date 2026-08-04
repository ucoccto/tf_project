# ────────────────────────────────────────────────
# WEB ECR 저장소
# ────────────────────────────────────────────────
resource "aws_ecr_repository" "web" {
  # 저장소 이름 "de-ai-25-eks-auto-dev/web"
  name = "${local.cluster_name}/web"
  
  # 이미지 태그
  # 같은 이미지 태그를 다시 push 할수 있다. -> 실습/개발할때 유용
  # 운영 환경에서는 버전번호, Commit ID등 을 활용하여 구분하는게 적절(안전)
  image_tag_mutability = "MUTABLE"
  
  # 테라폼 명령으로 destroy 실행시 이미지 부분 저장소와 함께 삭제할것인가?
  # 운영시에는 달라질수 있음
  force_delete = true

  # 이미지 push 할때 알려진 취약점들 자동 검사 처리
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { 
    Name = "${local.cluster_name}-ecr-web-repo" 
  }
}


# ────────────────────────────────────────────────
# WAS ECR 저장소
# ────────────────────────────────────────────────
resource "aws_ecr_repository" "was" {
  name = "${local.cluster_name}/was"
}