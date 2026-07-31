###################################
# web ec2용 -> launch template 요소(ASG 내에서 사용)를 사용하여 생성됨
###################################
resource "aws_launch_template" "web" {
  name_prefix = "${local.project}-WEB-" # 증감이 수시로 발생해도 중복 x
  image_id    = data.aws_ami.amazon_linux
  instance_type = var.instance_type
  # SSM 접속을 위해 프로파링 설정 -> iam.tf 구성
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm.name
  }
  # 보안 그룹 지정
  vpc_security_group_ids = [aws_security_group.web.id]
  # 서버 구성후 초기 작업 -> 쉘스크립트를 읽어서 => base64 인코딩처리 => 실행되게 구성
  user_data = base64decode( templatefile("${path.module}/userdata-web.sh.tftpl") )

}

###################################
# was ec2용 -> launch template 요소(ASG 내에서 사용)를 사용하여 생성됨
###################################