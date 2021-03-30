resource "metal_device" "ecsAnywhere_server" {
  count            = var.metal_host_count
  hostname         = format("%s%02d", var.metal_hostname, count.index + 1)
  plan             = var.metal_plan
  facilities       = var.metal_facility
  operating_system = var.metal_os
  user_data        = <<-EOF
          #!/bin/bash
          curl -o "/tmp/ecs-anywhere-install.sh" "https://amazon-ecs-agent-packages-preview.s3.us-east-1.amazonaws.com/ecs-anywhere-install.sh"
          cd /tmp
          awk 'NR==433{print "sed -i '/After=cloud-final.service/d' /usr/lib/systemd/system/ecs.service"}1' /tmp/ecs-anywhere-install.sh >/tmp/ecs-anywhere-install.sh1 && mv /tmp/ecs-anywhere-install.sh1 /tmp/ecs-anywhere-install.sh
          sudo chmod +x /tmp/ecs-anywhere-install.sh
          sudo ./ecs-anywhere-install.sh --cluster ecsAnywhere-cluster --activation-id ${aws_ssm_activation.ssm_activation_pair.id} --activation-code ${aws_ssm_activation.ssm_activation_pair.activation_code} --region eu-central-1
          EOF
  billing_cycle    = "hourly"
  project_id       = var.metal_project_id
}
