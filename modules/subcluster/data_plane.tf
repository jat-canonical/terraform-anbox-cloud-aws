resource "juju_application" "lxd" {
  name = "lxd"

  model       = var.model_name
  constraints = join(" ", var.constraints)

  charm {
    name    = "ams-lxd"
    channel = var.channel
  }

  config = {
    ua_token = var.ua_token
  }

  // units = var.lxd_nodes
  placement = join(",", juju_machine.data_plane[*].machine_id)
  // FIXME: Currently the provider has some issues with reconciling state using
  // the response from the JUJU APIs. This is done just to ignore the changes in
  // string values returned.
  lifecycle {
    ignore_changes = [constraints]
  }
}

resource "juju_application" "ams_node_controller" {
  name = "ams-node-controller"

  model = var.model_name
  // placement = join(",", juju_machine.data_plane[*].machine_id)

  charm {
    name    = "ams-node-controller"
    channel = var.channel
  }

  // The provider currently does not know properly about subordinate charms
  // So we specify 0 units as this will get attached automatically to the
  // principal charm after relation.
  units = 0

  config = {
    port = "10000-11000"
  }
  depends_on = [juju_application.lxd]
}

resource "juju_integration" "ip_table_rules" {
  model = var.model_name

  application {
    name     = juju_application.ams_node_controller.name
    endpoint = "lxd"
  }

  application {
    name     = juju_application.lxd.name
    endpoint = "api"
  }
}

resource "juju_integration" "ams_node" {
  model = var.model_name

  application {
    name     = juju_application.ams.name
    endpoint = "lxd"
  }

  application {
    name     = juju_application.lxd.name
    endpoint = "api"
  }
}

module "data_machines" {
  count               = var.lxd_nodes
  source              = "../aws_machine"
  user_ssh_pub_key    = var.machine_ssh_public_key
  user_ssh_priv_key   = var.machine_ssh_private_key
  machine_name_prefix = "data-plane"
  subnet              = var.subnet_id
  vpc_id              = var.vpc_id
}

resource "juju_machine" "data_plane" {
  count = var.lxd_nodes
  model = var.model_name
  // base        = local.base
  // constraints = join(" ", var.constraints)
  private_key_file = var.machine_ssh_private_key
  public_key_file  = var.machine_ssh_public_key
  ssh_address      = "ubuntu@${module.data_machines[count.index].instance_ip}"
  // FIXME: Currently the provider has some issues with reconciling state using
  // the response from the JUJU APIs. This is done just to ignore the changes in
  // string values returned.
  lifecycle {
    ignore_changes = [constraints]
  }
  depends_on = [module.data_machines]
}
