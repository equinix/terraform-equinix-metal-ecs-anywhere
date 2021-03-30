resource "aws_iam_role" "ecsAnywhereRole" {
  name = var.iam_role_name 

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore-role-policy-attach" {
  role       = "${aws_iam_role.ecsAnywhereRole.name}"
  policy_arn = "${data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn}"
  depends_on = [aws_iam_role.ecsAnywhereRole]
}

data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerServiceforEC2Role-role-policy-attach" {
  role       = "${aws_iam_role.ecsAnywhereRole.name}"
  policy_arn = "${data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn}"
  depends_on = [aws_iam_role.ecsAnywhereRole]
}
