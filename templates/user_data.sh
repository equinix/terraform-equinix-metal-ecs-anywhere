#!/bin/bash
sudo apt update

curl -o "/tmp/ecs-anywhere-install.sh" "https://amazon-ecs-agent-packages-preview.s3.us-east-1.amazonaws.com/ecs-anywhere-install.sh"
cd /tmp
awk 'NR==433{print "sed -i '/After=cloud-final.service/d' /usr/lib/systemd/system/ecs.service"}1' /tmp/ecs-anywhere-install.sh >/tmp/ecs-anywhere-install.sh1 && mv /tmp/ecs-anywhere-install.sh1 /tmp/ecs-anywhere-install.sh
sudo chmod +x /tmp/ecs-anywhere-install.sh
sudo /tmp/ecs-anywhere-install.sh --cluster ${ecs_cluster} --activation-id ${ssm_activation_pair} --activation-code ${activation_code} --region ${region}

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip -o awscliv2.zip
sudo ./aws/install

mkdir -p /data/sourcefolder
mkdir -p /data/destinationfolder