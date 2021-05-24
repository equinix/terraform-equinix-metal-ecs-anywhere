locals {
  cluster_name        = format("%s-%s", var.cluster_name, random_string.cluster_suffix.result)
  timestamp           = timestamp()
  timestamp_sanitized = replace(local.timestamp, "/[- TZ:]/", "")
  ssh_key_name        = format("ecs-%s-%s", var.cluster_name, random_string.cluster_suffix.result)
  project_id          = var.project_id
}

resource "random_string" "cluster_suffix" {
  length  = 5
  special = false
  upper   = false
}