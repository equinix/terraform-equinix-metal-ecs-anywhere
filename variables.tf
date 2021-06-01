variable "auth_token" {
  description = "Equinix Metal API Key"
}

variable "project_id" {
  description = "Equinix Metal Project ID"
}

variable "metro" {
  description = "Equinix Metal metro to deploy into"
}

variable "facility" {
  description = "Equinix Metal Facility to deploy into"
}

variable "worker_plan" {
  description = "Equinix Metal device type to deploy for worker nodes"
  default     = "c3.small.x86"
}

variable "worker_count" {
  type        = number
  description = "Number of baremetal worker nodes"
  default     = 3
}

variable "operating_system" {
  description = "The Operating system of the node"
  default     = "ubuntu_20_04"
}

variable "billing_cycle" {
  description = "How the node will be billed (Not usually changed)"
  default     = "hourly"
}

variable "cluster_name" {
  description = "The ECS cluster name"
}

# Advanced Variables below this line
variable "metal_connection_is_vlan_attached" {
  type        = bool
  description = "Set true only once the connection is approved and the vlan attached to the connection (required manual steps that are defined in the README file)"
  default     = false
}

variable "bgp_asn" {
  type        = number
  description = "BGP ASN to peer with Equinix Metal"
  default     = 65000
}

variable "eqx_metal_token" {
  description = "Equinix Metal Connection Token"
}

variable "local_asn" {
  type        = number
  description = "Local ASN to configure BGP sessions"
  default     = 65321
}

variable "metal_asn" {
  description = "Equinic Metal - Local BGP Autonomous System Number (ASN)"
  default     = 65000
}

variable "cluster_private_network" {
  description = "First three octets for the private IPs in the cluster"
  default     = "192.168.100"
}

# Equinix Fabric variables

variable "eqx_consumer_key" {
  description = "Equinix App Consumer Key"
}

variable "eqx_consumer_secret" {
  description = "Equinix App Consumer Secret"
}

variable "eqx_seller_ne_metro_code" {
  description = "Metro Code in Equinix for NE Device"
}

variable "eqx_seller_aws_metro_code" {
  description = "Metro Code in Equinix for AWS Connections"
}

variable "eqx_seller_metal_metro_code" {
  description = "Metro Code in Equinix for Metal Connections"
}

variable "eqx_fabric_speed" {
  description = "Speed for the NE connection, must be allowed by the platform and seller"
}

variable "eqx_fabric_speed_unit" {
  description = "MB / GB, must be allowed by the platform and the seller"
}

variable "eqx_ne_device_hw_platform" {
  description = "Device hardware platform flavor: small, medium, large"
  default     = "small"
}

variable "eqx_ne_throughput" {
  type        = number
  description = "Device license throughput"
}

variable "eqx_ne_throughput_unit" {
  description = "License throughput unit (Mbps or Gbps)"
}

variable "eqx_ne_ssh_user" {
  description = "Device - SSH user login name"
}

variable "eqx_ne_ssh_pwd" {
  description = "Device - SSH user password"
}

variable "eqx_account" {
  description = "Billing account number for a device"
}

variable "eqx_device_hostname" {
  description = "Device hostname prefix"
}

variable "eqx_ne_acl_template_name" {
  description = "Name of the new ACL template to be attached to the NE device"
}

variable "eqx_notification_users" {
  type        = list(string)
  description = "List of emails to notify about changes"
}

# AWS  variables

variable "aws_account" {
  description = "AWS Account"
}

variable "aws_region" {
  description = "AWS region to create resources"
}

variable "iam_role_name" {
  description = "Name your IAM Role for SSM register"
  type        = string
  default     = "ecsAnywhereRole"
}

variable "ecs_cluster_name" {
  description = "Name for your ECS cluster"
  type        = string
  default     = "ecsAnywhere-cluster"
}

variable "ecs_task_name" {
  description = "Name for your ECS task definition"
  type        = string
  default     = "nginx-external"
}

variable "ecs_container_name" {
  description = "Name for your ECS container"
  type        = string
  default     = "nginx"
}

variable "ecs_container_image" {
  description = "URL image for container"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:latest"
}

variable "ecs_cpu" {
  description = "CPU assigned to your container"
  type        = number
  default     = 256
}

variable "ecs_memory" {
  description = "Memory assigned to your container"
  type        = number
  default     = 256
}

variable "ecs_containerPort" {
  description = "ContainerPort"
  type        = number
  default     = 80
}

variable "ecs_hostPort" {
  description = "hostPort"
  type        = number
  default     = 8080
}

variable "aws_network_cidr" {
  description = "VPC network ip block."
}

variable "aws_subnet1_cidr" {
  description = "Subset block from VPC network ip block."
}

variable "aws_dx_bgp_equinix_side_asn" {
  description = "The autonomous system (AS) number for Border Gateway Protocol (BGP) configuration. Each BGP interface may use a different value. (Equinix side)"
}

variable "aws_dx_bgp_authkey" {
  description = "The authentication key for BGP configuration. Special characters may conflict in the router configuration"
}

variable "aws_dx_bgp_amazon_address" {
  description = "The IPv4 CIDR address to use to send traffic to Amazon. Required for IPv4 BGP peers"
}

variable "aws_dx_bgp_equinix_side_address" {
  description = "The IPv4 CIDR destination address to which Amazon should send traffic. Required for IPv4 BGP peers (Equinix side)"
}

variable "aws_vpc_endpoint_services" {
  description = "List for the name of the services you want to enable a VPC endpoint"
  type        = list(string)
  default     = ["ecs", "ecs-agent", "ecs-telemetry", "s3", "sqs"]
}

variable "aws_access_key" {
  description = "AWS access key"
}

variable "aws_secret_key" {
  description = "AWS secret key"
}
