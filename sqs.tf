resource "aws_sqs_queue" "ecs" {
  name = var.cluster_name
}