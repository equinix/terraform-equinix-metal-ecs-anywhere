output "aws-region" {
  value = var.aws_region
}

output "ecs-cluster" {
  value = var.ecs_cluster_name
}

output "ecr-url" {
  value = aws_ecr_repository.ecs.repository_url
}

output "sqs-url" {
  value = "https://${aws_vpc_endpoint.endpoints[index(var.aws_vpc_endpoint_services, "sqs")].dns_entry[0].dns_name}/${aws_sqs_queue.ecs.name}"
}

output "sqs-url-public" {
  value = aws_sqs_queue.ecs.id
}

output "iam-exec-role" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "iam-task-role" {
  value = aws_iam_role.ecs_task_role.arn
}

output "activation_code" {
  value = aws_ssm_activation.ssm_activation_pair.activation_code
}

output "ssm_activation_pair" {
  value = aws_ssm_activation.ssm_activation_pair.id
}