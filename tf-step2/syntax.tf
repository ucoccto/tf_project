# 1. 변수
# 변수 선언 및 값 세팅
variable "name" {
  # 문자열 타입
  default = "테라폼"
}
variable "age" {
  # 수치 타입
  default = 100
}
variable "is_mz" {
  # 불린 타입
  default = true
}
variable "books" {
  # 리스트 타입
  default = ["1","2"]
}
variable "stations" {
  # map 타입
  default = {
    A="영등포역",
    B=100
  }
}
# 출력
output "name" {
  value = var.name
}
output "age" {
  value = var.age
}
output "is_mz" {
  value = var.is_mz
}
output "books" {
  value = var.books
}
output "stations" {
  value = var.name
}