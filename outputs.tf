output "ssm_activation_id" {
  value = aws_ssm_activation.ssm_activation_pair.id
}

output "ssm_activation_code" {
  value = aws_ssm_activation.ssm_activation_pair.activation_code
}
