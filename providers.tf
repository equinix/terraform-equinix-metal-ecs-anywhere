provider "metal" {
  auth_token = var.auth_token
}

provider "equinix" {
  client_id     = var.eqx_consumer_key
  client_secret = var.eqx_consumer_secret
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project    = var.cluster_name
      CostCenter = var.cluster_name
    }
  }
}