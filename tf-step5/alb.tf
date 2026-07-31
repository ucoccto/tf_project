#################################
# public ALB : Internet <-> ALB <-> WEB ASG
#################################
resource "aws_lb" "public" {
  name               = "${local.project}-public-alb"
  internal           = false
  load_balancer_type = "application"
  # 보안그룹 - 퍼블릭 ALB
  security_groups    = [aws_security_group.public_alb.id]
  # 퍼블릭 서브넷 2개 (가용영역별 a, c) 각각 id를 추출(리스트 컴프리핸션 방식 문법) 반영
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  tags = { Name = "${local.project}-PUBLIC-ALB" }
}
resource "aws_lb_target_group" "web" {
  name        = "${local.project}-web-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = { Name = "${local.project}-WEB-TG" }
}
resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

#################################
# internal ALB : WEB ASG <-> Internal ALB <-> WAS ASG
#################################
resource "aws_lb" "internal" {
  name               = "${local.project}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb.id]
  # APP 프라이빗 서브넷 2개 (가용영역별 a, c) 각각 id를 추출(리스트 컴프리핸션 방식 문법) 반영
  subnets            = [for subnet in aws_subnet.app : subnet.id]
  tags = { Name = "${local.project}-INTERNAL-ALB" }
}
resource "aws_lb_target_group" "was" {
  name        = "${local.project}-was-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = { Name = "${local.project}-WAS-TG" }
}
resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 8000
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.was.arn
  }
}