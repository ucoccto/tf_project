# ────────────────────────────────────────────────
# 공통 환경 변수
# ────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}
variable "project_name" {
  description = "리소스명에 사용할 프로젝트명"
  type        = string
  default     = "de-ai-25-eks-auto"
}
variable "environment" {
  description = "구동 환경"
  type        = string
  default     = "dev"
}




variable "instance_type" {
  description = "WEB/WAS EC 인스턴스 유형"
  type        = string
  default     = "t3.micro"
}
variable "web_desired_capacity" {
  description = "WEB ASG 기본 인스턴스 수"
  type        = number
  default     = 2
}
variable "was_desired_capacity" {
  description = "WAS ASG 기본 인스턴스 수"
  type        = number
  default     = 2
}
variable "db_instance_class" {
  description = "DB 인스턴스 클레스"
  type        = string
  default     = "db.t3.micro"
}
variable "db_name" {
  description = "초기 생성 데이터베이스 이름"
  type        = string
  default     = "appdb"
}
variable "db_username" {
  description = "RDS 관리자 이름"
  type        = string
  default     = "adminuser"
}