resource "aws_key_pair" "machine" {
  key_name   = "${var.machine_name_prefix}-machine-keypair"
  public_key = file(var.user_ssh_pub_key)
}

resource "aws_security_group" "sg" {
  name        = "${var.machine_name_prefix}-machine-sg"
  description = "Allow SSH to machine"
  vpc_id      = var.vpc_id
  ingress {
    description = "Allow SSH from anywhere"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "machine" {
  subnet_id       = var.subnet
  security_groups = [aws_security_group.sg.id]
  tags = {
    Name = "${var.machine_name_prefix} machine network interface"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# This little dance is to ensure we don't replace the machine machine if the ami is updated.
# If the machine already exists, we'll configure terraform with the ami of the existing machine,
# otherwise we'll use the latest from data.aws_ami.ubuntu
data "aws_instances" "machine" {
  filter {
    name   = "tag:Name"
    values = ["${var.machine_name_prefix} machine"]
  }
  instance_state_names = ["running", "pending", "shutting-down", "stopped", "stopping"]
}

data "aws_instance" "machine" {
  count       = length(data.aws_instances.machine.ids) == 1 ? 1 : 0
  instance_id = one(data.aws_instances.machine.ids)
}

resource "aws_instance" "juju_machine" {
  ami           = coalesce(one(data.aws_instance.machine[*].ami), data.aws_ami.ubuntu.id)
  instance_type = "t2.medium"
  key_name      = aws_key_pair.machine.key_name
  root_block_device {
    volume_size = 30
  }
  network_interface {
    network_interface_id = aws_network_interface.machine.id
    device_index         = 0
  }
  tags = {
    Name = "${var.machine_name_prefix} machine"
  }

  provisioner "remote-exec" {
    connection {
      host  = aws_instance.juju_machine.public_ip
      user  = "ubuntu"
      agent = true
    }
    inline = ["echo reachable"]
  }
}
