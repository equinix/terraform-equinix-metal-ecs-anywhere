data "equinix_network_device_type" "router" {
  name = "CSR 1000V"
}

data "equinix_network_device_platform" "router" {
  device_type = data.equinix_network_device_type.router.code
  flavor      = var.eqx_ne_device_hw_platform
}

resource "equinix_network_device" "router" {
  name            = var.cluster_name
  type_code       = data.equinix_network_device_type.router.code
  hostname        = var.eqx_device_hostname
  byol            = false
  metro_code      = var.eqx_seller_ne_metro_code
  notifications   = var.eqx_notification_users
  package_code    = "APPX"
  term_length     = 1
  throughput      = var.eqx_ne_throughput
  throughput_unit = var.eqx_ne_throughput_unit
  account_number  = var.eqx_account
  interface_count = 10
  core_count      = data.equinix_network_device_platform.router.core_count
  version         = "16.09.05"
  self_managed    = false
  acl_template_id = equinix_network_acl_template.acl.id
}

resource "equinix_network_ssh_user" "router" {
  username   = var.eqx_ne_ssh_user
  password   = var.eqx_ne_ssh_pwd
  device_ids = [equinix_network_device.router.id]
}

resource "equinix_network_acl_template" "acl" {
  name        = var.eqx_ne_acl_template_name
  description = "Configure device automatically"
  metro_code  = var.eqx_seller_ne_metro_code

  inbound_rule {
    subnets  = ["0.0.0.0/0"]
    protocol = "TCP"
    src_port = "any"
    dst_port = "22"
  }
}

resource "equinix_network_bgp" "metal" {
  count = var.metal_connection_is_vlan_attached ? 1 : 0

  depends_on = [
    equinix_ecx_l2_connection.metal
  ]

  connection_id     = equinix_ecx_l2_connection.metal.id
  local_asn         = var.local_asn
  local_ip_address  = "${var.cluster_private_network}.254/24"
  remote_asn        = var.metal_asn
  remote_ip_address = "${var.cluster_private_network}.1"
}

resource "equinix_network_bgp" "aws" {
  connection_id      = equinix_ecx_l2_connection.aws.id
  local_ip_address   = var.aws_dx_bgp_equinix_side_address
  local_asn          = var.local_asn
  remote_ip_address  = cidrhost(var.aws_dx_bgp_amazon_address, 1)
  remote_asn         = 64512 // Default AWS ASN for the Direct Connect Gateway if you don't choose one
  authentication_key = var.aws_dx_bgp_authkey
}

resource "null_resource" "configure_cisco" {
  depends_on = [
    equinix_network_bgp.aws
  ]

  triggers = {
    connection_ids = join(",", concat([equinix_network_bgp.aws.id], equinix_network_bgp.metal.*.id))
  }

  provisioner "local-exec" {
    command = "python3 -m pip install netmiko"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${path.module}/templates/config_cisco.py"
    environment = {
      HOST      = equinix_network_device.router.ssh_ip_address,
      USER      = equinix_network_ssh_user.router.username,
      PASSWORD  = equinix_network_ssh_user.router.password,
      LOCAL_ASN = var.local_asn
    }
  }
}
