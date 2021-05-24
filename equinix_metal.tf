resource "metal_vlan" "vlan" {
  description = format("AWS ECS Anywhere - VLAN for Equinix Fabric in %s", lower(var.facility))
  facility    = lower(var.facility)
  project_id  = local.project_id
}

resource "tls_private_key" "ssh_key_pair" {
  count = var.metal_connection_is_vlan_attached ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "metal_ssh_key" "ssh_pub_key" {
  count = var.metal_connection_is_vlan_attached ? 1 : 0

  name       = local.cluster_name
  public_key = chomp(tls_private_key.ssh_key_pair.0.public_key_openssh)
}

data "template_file" "user_data" {
  count = var.metal_connection_is_vlan_attached ? 1 : 0

  template = file("templates/user_data.sh")
  vars = {
    activation_code     = aws_ssm_activation.ssm_activation_pair.activation_code
    ssm_activation_pair = aws_ssm_activation.ssm_activation_pair.id
    region              = var.aws_region
  }
}

resource "metal_device" "worker_nodes" {
  count            = var.metal_connection_is_vlan_attached ? var.worker_count : 0
  hostname         = format("%s-worker-%02d", local.cluster_name, count.index + 1)
  plan             = var.worker_plan
  metro            = var.metro
  operating_system = var.operating_system
  billing_cycle    = var.billing_cycle
  project_id       = local.project_id
  tags             = ["anthos", "baremetal", "worker"]
}

resource "metal_device_network_type" "worker_nodes" {
  count = var.metal_connection_is_vlan_attached ? var.worker_count : 0

  device_id = metal_device.worker_nodes.*.id[count.index]
  type      = "hybrid"
}

resource "metal_port_vlan_attachment" "worker_nodes" {
  count = var.metal_connection_is_vlan_attached ? var.worker_count : 0

  depends_on = [
    metal_device_network_type.worker_nodes
  ]
  device_id  = metal_device.worker_nodes.*.id[count.index]
  port_name  = "eth1"
  vlan_vnid  = metal_vlan.vlan.vxlan
  force_bond = true
}

data "template_file" "private_network_worker" {
  count = var.metal_connection_is_vlan_attached ? var.worker_count : 0

  template = file("templates/private_network.sh")
  vars = {
    vlan_id         = metal_vlan.vlan.vxlan
    private_ip      = count.index + 10
    private_network = var.cluster_private_network
    aws_subnet_cidr = var.aws_network_cidr
  }
}

resource "null_resource" "private_network_worker" {
  count = var.metal_connection_is_vlan_attached ? var.worker_count : 0

  triggers = {
    template     = data.template_file.private_network_worker.*.rendered[count.index],
    instance_ids = join(",", metal_device.worker_nodes.*.id)
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = chomp(tls_private_key.ssh_key_pair.0.private_key_pem)
    host        = metal_device.worker_nodes.*.access_public_ipv4[count.index]
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /root/bootstrap/"
    ]
  }

  provisioner "file" {
    content     = data.template_file.private_network_worker.*.rendered[count.index]
    destination = "/root/bootstrap/private_network_worker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /root/bootstrap/private_network_worker.sh"
    ]
  }
}

resource "null_resource" "install_ecs_agent" {
  count = var.metal_connection_is_vlan_attached ? var.worker_count : 0

  depends_on = [
    null_resource.private_network_worker
  ]

  triggers = {
    template     = data.template_file.user_data.0.rendered,
    instance_ids = join(",", metal_device.worker_nodes.*.id)
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = chomp(tls_private_key.ssh_key_pair.0.private_key_pem)
    host        = metal_device.worker_nodes.*.access_public_ipv4[count.index]
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /root/bootstrap/"
    ]
  }

  provisioner "file" {
    content     = data.template_file.user_data.0.rendered
    destination = "/root/bootstrap/user_data.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /root/bootstrap/user_data.sh"
    ]
  }
}