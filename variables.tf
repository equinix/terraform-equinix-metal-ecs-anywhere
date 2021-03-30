variable "metal_key" {
  description = "This is your Equinix Metal API Auth token"
  type        = string
}

variable "aws_access_key" {
  description = "This is your AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "This is your AWS secret key"
  type        = string
}

variable "aws_region" {
  description = "This is your AWS region"
  type        = string
  default     = "eu-central-1"
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

variable "metal_host_count" {
  description = "Number of ECS external servers"
  type        = number
  default     = 3
}

variable "metal_hostname" {
  description = "Hostname for your server"
  type        = string
  default     = "ecs-anywhere-"
}

variable "metal_plan" {
  description = "Server type"
  type        = string
  default     = "c3.small.x86"
}

variable "metal_facility" {
  description = "Equinix location"
  type        = list(string)
  default     = ["fr2"]
}

variable "metal_os" {
  description = "Operating System for your Equinix Metal server"
  type        = string
  default     = "centos_8"
}

variable "metal_project_id" {
  description = "Equinix Metal Project ID"
  type        = string
}
