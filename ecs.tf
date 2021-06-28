resource "aws_ecs_cluster" "ecs-cluster" {
  name = var.cluster_name
}

resource "aws_ecr_repository" "ecs" {
  name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "ecs-external-${var.ecs_cluster_name}"
}

resource "aws_ecs_task_definition" "task" {
  container_definitions = jsonencode(
    [
      {
        cpu       = 256
        essential = true
        image     = aws_ecr_repository.ecs.repository_url
        memory    = 512
        name      = "ecsworker-external"

        mountPoints = [
          {
            containerPath = "/data"
            sourceVolume  = "share"
          },
        ]

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "ecs-external-${aws_ecs_cluster.ecs-cluster.name}"
            awslogs-region        = var.aws_region
            awslogs-stream-prefix = "external"
          }
        }

        environment = [
          {
            name  = "AWS_REGION"
            value = var.aws_region
          },
          {
            name  = "EFS_DESTINATION_FOLDER"
            value = "/data/destinationfolder/"
          },
          {
            name  = "EFS_SOURCE_FOLDER"
            value = "/data/sourcefolder/"
          },
          {
            name  = "SQS_QUEUE_URL"
            value = "https://${aws_vpc_endpoint.endpoints[index(var.aws_vpc_endpoint_services, "sqs")].dns_entry[0].dns_name}/${aws_sqs_queue.ecs.name}"
          },
        ]
      },
    ]
  )

  volume {
    name      = "share"
    host_path = "/data"
  }

  family                   = "service"
  requires_compatibilities = ["EXTERNAL"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
}

resource "aws_ecs_service" "demo" {
  name            = "ecsworker-external-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "EXTERNAL"
}