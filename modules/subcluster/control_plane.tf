resource "juju_application" "ams" {
  name = "ams"

  model       = var.model_name
  constraints = join(" ", var.constraints)

  charm {
    name    = "ams"
    channel = var.channel
  }

  units     = 1
  placement = juju_machine.control_plane.machine_id

  config = {
    ua_token          = var.ua_token
    use_embedded_etcd = !var.external_etcd
  }

  // FIXME: Currently the provider has some issues with reconciling state using
  // the response from the JUJU APIs. This is done just to ignore the changes in
  // string values returned.
  lifecycle {
    ignore_changes = [constraints]
  }

  depends_on = [juju_machine.control_plane]
}

resource "juju_application" "etcd" {
  count = var.external_etcd ? 1 : 0
  name  = "etcd"

  model       = var.model_name
  constraints = join(" ", var.constraints)
  placement   = juju_machine.control_plane.machine_id

  charm {
    name    = "etcd"
    channel = "latest/stable"
  }

  config = {
    channel = "3.4/stable"
  }

  units = 1
  // FIXME: Currently the provider has some issues with reconciling state using
  // the response from the JUJU APIs. This is done just to ignore the changes in
  // string values returned.
  lifecycle {
    ignore_changes = [constraints]
  }
  depends_on = [juju_machine.control_plane]
}

resource "juju_application" "etcd_ca" {
  count = var.external_etcd ? 1 : 0
  name  = "etcd-ca"

  model       = var.model_name
  constraints = join(" ", var.constraints)
  placement   = juju_machine.control_plane.machine_id

  charm {
    name    = "easyrsa"
    channel = "latest/stable"
  }

  units      = 1
  depends_on = [juju_machine.control_plane]
}

resource "juju_integration" "ams_db" {
  count = var.external_etcd ? 1 : 0
  model = var.model_name

  application {
    name     = juju_application.ams.name
    endpoint = "etcd"
  }

  application {
    name     = one(juju_application.etcd[*].name)
    endpoint = "db"
  }
}

resource "juju_integration" "etcd_ca" {
  count = var.external_etcd ? 1 : 0
  model = var.model_name

  application {
    name     = one(juju_application.etcd_ca[*].name)
    endpoint = "client"
  }

  application {
    name     = one(juju_application.etcd[*].name)
    endpoint = "certificates"
  }
}

module "control_machine" {
  source              = "../aws_machine"
  user_ssh_pub_key    = var.machine_ssh_public_key
  user_ssh_priv_key   = var.machine_ssh_private_key
  machine_name_prefix = "control-plane"
  subnet              = var.subnet_id
  vpc_id              = var.vpc_id
}

resource "juju_machine" "control_plane" {
  model = var.model_name
  // base        = local.base
  // constraints = join(" ", var.constraints)
  private_key_file = var.machine_ssh_private_key
  public_key_file  = var.machine_ssh_public_key
  ssh_address      = "ubuntu@${module.control_machine.instance_ip}"
  // FIXME: Currently the provider has some issues with reconciling state using
  // the response from the JUJU APIs. This is done just to ignore the changes in
  // string values returned.
  // lifecycle {
  //   ignore_changes = [constraints]
  // }
  depends_on = [module.control_machine]
}
