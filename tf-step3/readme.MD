# 목표
- 회사 전용으로 클라우드내 네트워크 구축 -> VPC
- 현재 EC2는 defaults VPC 사용 -> 전용 VPC로 직접 생성하여 적용
- [v] VPC만 구축 (가장 먼서 선행할 작업)
    -> [v] EC2에 커스텀 VPC 연결 하여 인프라구성 
    -> web(public subnet), was/db(private subnet) 확장 + NAT gateway, SSH Manager, IAM Role
    -> 소스코드, 쿠버네티스, CI/CD
    -> 대시보드 (그라파타, 프로메테우스,..)

