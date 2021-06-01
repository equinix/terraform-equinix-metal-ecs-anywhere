output "aws-region" {
  description = "AWS region where resources were deployed"
  value       = var.aws_region
}

output "ecs-cluster" {
  description = "Name of the ECS cluster created"
  value       = var.ecs_cluster_name
}

output "ecr-url" {
  description = "URL of the ECR created to push container images"
  value       = aws_ecr_repository.ecs.repository_url
}

output "sqs-url" {
  description = "SQS URL to use to access privately the SQS endpoint"
  value       = "https://${aws_vpc_endpoint.endpoints[index(var.aws_vpc_endpoint_services, "sqs")].dns_entry[0].dns_name}/${aws_sqs_queue.ecs.name}"
}

output "sqs-url-public" {
  description = "SQS URL to use to access publicly the SQS endpoint"
  value       = aws_sqs_queue.ecs.id
}

output "iam-exec-role" {
  description = "ARN of the IAM role to execute ECS tasks"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "iam-task-role" {
  description = "ARN of the IAM role that the ECS tasks will use"
  value       = aws_iam_role.ecs_task_role.arn
}

output "activation_code" {
  description = "SSM activation code to register the ECS agent"
  value       = aws_ssm_activation.ssm_activation_pair.activation_code
}

output "ssm_activation_pair" {
  description = "SSM activation pair to register the ECS agent"
  value       = aws_ssm_activation.ssm_activation_pair.id
}