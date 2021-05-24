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
  role       = aws_iam_role.ecsAnywhereRole.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  depends_on = [aws_iam_role.ecsAnywhereRole]
}

data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerServiceforEC2Role-role-policy-attach" {
  role       = aws_iam_role.ecsAnywhereRole.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn
  depends_on = [aws_iam_role.ecsAnywhereRole]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.cluster_name}-role-name-exec"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.cluster_name}-role-name-task"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF

  inline_policy {
    name = "sqs-permissions"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Sid" : "",
          "Action" : "sqs:*",
          "Effect" : "Allow",
          "Resource" : "arn:aws:sqs:${var.aws_region}:${var.aws_account}:${aws_sqs_queue.ecs.name}",
        },
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}