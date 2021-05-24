resource "aws_vpn_gateway" "ecs" {
  vpc_id = aws_vpc.aws-vpc.id
}

resource "equinix_ecx_l2_connection_accepter" "aws" {
  connection_id = equinix_ecx_l2_connection.aws.id
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
}

resource "aws_dx_private_virtual_interface" "ecs" {
  connection_id    = equinix_ecx_l2_connection_accepter.aws.aws_connection_id
  name             = "${var.cluster_name}-vif"
  vlan             = equinix_ecx_l2_connection.aws.zside_vlan_stag
  address_family   = "ipv4"
  bgp_asn          = var.local_asn
  bgp_auth_key     = var.aws_dx_bgp_authkey
  amazon_address   = var.aws_dx_bgp_amazon_address
  customer_address = var.aws_dx_bgp_equinix_side_address
  vpn_gateway_id   = aws_vpn_gateway.ecs.id
}

resource "aws_vpc" "aws-vpc" {
  depends_on = [equinix_ecx_l2_connection_accepter.aws]

  cidr_block           = var.aws_network_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "aws-subnet-1" {
  vpc_id     = aws_vpc.aws-vpc.id
  cidr_block = var.aws_subnet1_cidr
}

resource "aws_internet_gateway" "aws-vpc-igw" {
  vpc_id = aws_vpc.aws-vpc.id
}

resource "aws_default_route_table" "aws-vpc" {
  default_route_table_id = aws_vpc.aws-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-vpc-igw.id
  }

  propagating_vgws = [aws_vpn_gateway.ecs.id]
}

resource "aws_route_table_association" "ecs" {
  subnet_id      = aws_subnet.aws-subnet-1.id
  route_table_id = aws_vpc.aws-vpc.default_route_table_id
}
