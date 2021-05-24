data "equinix_ecx_l2_sellerprofile" "aws" {
  name = "AWS Direct Connect"
}

resource "equinix_ecx_l2_connection" "aws" {
  name              = "${var.cluster_name}-aws"
  profile_uuid      = data.equinix_ecx_l2_sellerprofile.aws.uuid
  speed             = var.eqx_fabric_speed
  speed_unit        = var.eqx_fabric_speed_unit
  notifications     = var.eqx_notification_users
  device_uuid       = equinix_network_device.router.id
  seller_region     = var.aws_region
  seller_metro_code = var.eqx_seller_aws_metro_code
  authorization_key = var.aws_account
}

data "equinix_ecx_l2_sellerprofile" "metal" {
  name = "Equinix Metal - Layer 2"
}

resource "equinix_ecx_l2_connection" "metal" {
  name              = "${var.cluster_name}-metal"
  profile_uuid      = data.equinix_ecx_l2_sellerprofile.metal.uuid
  speed             = var.eqx_fabric_speed
  speed_unit        = var.eqx_fabric_speed_unit
  notifications     = var.eqx_notification_users
  device_uuid       = equinix_network_device.router.id
  seller_region     = var.facility
  seller_metro_code = var.eqx_seller_metal_metro_code
  authorization_key = var.eqx_metal_token
}
