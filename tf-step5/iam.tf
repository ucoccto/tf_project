data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ec2_ssm" {
  name               = "${local.project}-EC2-SSM-Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${local.project}-EC2-SSM-Profile"
  role = aws_iam_role.ec2_ssm.name
}
