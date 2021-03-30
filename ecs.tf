resource "aws_ecs_cluster" "ecsAnywhere-cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "nginx-external" {
  family       = var.ecs_task_name
  network_mode = "bridge" 
  container_definitions = jsonencode([
    {
      name      = var.ecs_container_name
      image     = var.ecs_container_image
      cpu       = var.ecs_cpu
      memory    = var.ecs_memory
      essential = true
      portMappings = [
        {
          containerPort = var.ecs_containerPort
          hostPort      = var.ecs_hostPort
        }
      ]
    }
  ])
}
