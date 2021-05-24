resource "aws_ecs_cluster" "ecsAnywhere-cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecr_repository" "ecs" {
  name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "ecs-external-${var.ecs_cluster_name}"
}