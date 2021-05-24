data "aws_ami" "aws-ami-ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_network_interface" "aws-vm" {
  subnet_id         = aws_subnet.aws-subnet-1.id
  source_dest_check = false
  security_groups = [
    aws_security_group.aws-allow-icmp.id,
    aws_security_group.aws-allow-ssh.id,
    aws_security_group.aws-allow-internet.id,
  ]
}

resource "aws_instance" "aws-vm" {
  ami           = data.aws_ami.aws-ami-ubuntu.id
  instance_type = "t2.micro"
  key_name      = "cm-macpro"

  network_interface {
    network_interface_id = aws_network_interface.aws-vm.id
    device_index         = 0
  }
}

resource "aws_security_group" "aws-allow-icmp" {
  name        = "aws-allow-icmp"
  description = "Allow icmp access from anywhere"
  vpc_id      = aws_vpc.aws-vpc.id

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "aws-allow-ssh" {
  name        = "aws-allow-ssh"
  description = "Allow ssh access from anywhere"
  vpc_id      = aws_vpc.aws-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "aws-allow-internet" {
  name        = "aws-allow-internet"
  description = "Allow http traffic from the internet"
  vpc_id      = aws_vpc.aws-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}