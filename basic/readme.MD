# 개요
- 기본 구성
- EC2 구성
- 문법

# 작업 
## 기본 구성
- 기본 파일 생성 (작업 디렉토리 : ~/basic)
```
provider.tf
main.tf
variables.tf
outputs.tf
terraform.tfvars
.gitignore
```

- provider.tf 작성

## 인프라구성 
- step1 : 테라폼 초기화 (init)
```
terraform init
---
성공후 결과물
-> .terraform : 공급자 플러그인, 바이너리, 모듈캐시, 정보등 저장
-> .terraform.lock.hcl : 프로바이더의 모듈의 정확한 버전, 해시값 잠금 -> 안정성, 자동생성시 체킹 파일
```

- step2 : 문법 검사(체킹) (validate)
```
terraform validate
---
Success! The configuration is valid.
```



## EC2 구성
