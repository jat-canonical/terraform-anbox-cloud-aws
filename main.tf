data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az1 = coalesce(var.az1, data.aws_availability_zones.available.names[0])
  az2 = coalesce(var.az2, data.aws_availability_zones.available.names[1])
  az3 = coalesce(var.az3, data.aws_availability_zones.available.names[2])
  model_names = flatten(
    [for region, clusters in var.subclusters_per_region : [for cluster_name in clusters : "${region}.${cluster_name}"]]
  )
}


module "subcluster" {
  for_each                = juju_model.anbox_cloud
  source                  = "./modules/subcluster"
  model_name              = juju_model.anbox_cloud[each.key].name
  ua_token                = var.ua_token
  channel                 = "1.21/stable"
  external_etcd           = true
  constraints             = var.constraints
  lxd_nodes               = var.lxd_nodes_per_subcluster
  deploy_streaming_stack  = false
  deploy_dashboard        = false
  deploy_lb               = false
  vpc_id                  = aws_vpc.main.id
  machine_ssh_public_key  = "~/.ssh/id_rsa.pub"
  machine_ssh_private_key = "~/.ssh/id_rsa"
  subnet_id               = aws_subnet.public_1.id
}

resource "juju_model" "anbox_cloud" {
  for_each = toset(local.model_names)
  name     = "anbox-cloud-${replace(each.value, ".", "-")}"

  cloud {
    name   = var.cloud_name
    region = split(".", each.value)[0]
  }

  constraints = join(" ", var.constraints)

  config = {
    logging-config              = "<root>=INFO"
    update-status-hook-interval = "5m"
  }
}
