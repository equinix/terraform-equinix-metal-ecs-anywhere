resource "aws_ssm_activation" "ssm_activation_pair" {
  name               = "ssm_activation_pair"
  description        = "ssmActivationPair"
  registration_limit = var.worker_count
  iam_role           = aws_iam_role.ecsAnywhereRole.id
  depends_on = [
    aws_iam_role_policy_attachment.AmazonSSMManagedInstanceCore-role-policy-attach,
    aws_iam_role_policy_attachment.AmazonEC2ContainerServiceforEC2Role-role-policy-attach
  ]
}