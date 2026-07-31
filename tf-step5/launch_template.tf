###################################
# web ec2용 -> launch template 요소(ASG 내에서 사용)를 사용하여 생성됨
###################################
resource "aws_launch_template" "web" {
  name_prefix = "${local.project}-WEB-" # 증감이 수시로 발생해도 중복 x
  image_id    = data.aws_ami.amazon_linux
}

###################################
# was ec2용 -> launch template 요소(ASG 내에서 사용)를 사용하여 생성됨
###################################