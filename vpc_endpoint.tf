resource "aws_security_group" "vpc-endpoints" {
  name        = "aws-allow-vpc-endpoints"
  description = "Allow HTTPS access from Equinix Metal"
  vpc_id      = aws_vpc.aws-vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.cluster_private_network}.0/24"]
  }
}

resource "aws_vpc_endpoint" "endpoints" {
  count             = length(var.aws_vpc_endpoint_services)
  vpc_id            = aws_vpc.aws-vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.${var.aws_vpc_endpoint_services[count.index]}"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.aws-subnet-1.id]

  security_group_ids = [
    aws_security_group.vpc-endpoints.id,
  ]
}