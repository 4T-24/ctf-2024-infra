module "bootstrap" {
  source = "./modules/bootstrap"

  public_key_pair_name = "k0s"
  public_key_pair_path = var.public_key_pair_path
}

module "network" {
  source = "./modules/network"

  name                = "k0s"
  cidr                = var.network_cidr_v4
  external_network_id = var.network_external_id
  dns_servers         = var.network_dns_servers

  depends_on = [module.bootstrap]
}

module "security_groups" {
  source = "./modules/security-groups"

  cidr = var.network_cidr_v4
}

module "control_plane" {
  source = "./modules/instance"
  count  = var.control_plane_number

  name      = "k0s-control-plane${count.index}"
  image_id  = var.control_plane_image_id
  flavor_id = var.control_plane_flavor_id

  public_key_pair = module.bootstrap.public_key_pair_name
  private_key_pair = var.private_key_pair_path
  ssh_login_name  = var.ssh_login_name

  security_groups = [
    module.security_groups.ssh_name,
    module.security_groups.control_plane_api_name,
    module.security_groups.controller_name,
    module.security_groups.worker_name
  ]

  network = {
    name             = module.network.name
    floating_ip_pool = var.network_floating_ip_pool
  }

  depends_on = [module.bootstrap, module.network, module.security_groups]
}

module "worker" {
  source = "./modules/instance"
  count  = var.worker_number

  name      = "k0s-worker${count.index}"
  image_id  = var.worker_image_id
  flavor_id = var.worker_flavor_id

  public_key_pair = module.bootstrap.public_key_pair_name
  private_key_pair = var.private_key_pair_path
  ssh_login_name  = var.ssh_login_name

  security_groups = [
    module.security_groups.ssh_name,
    module.security_groups.worker_name,
    module.security_groups.http_name
  ]

  network = {
    name             = module.network.name
    floating_ip_pool = var.network_floating_ip_pool
  }

  user_data = data.cloudinit_config.worker.rendered

  depends_on = [module.bootstrap, module.network, module.security_groups]
}

module "load_balancer" {
  source = "./modules/instance"
  count  = "1"

  name      = "k0s-lb${count.index}"
  image_id  = var.worker_image_id
  flavor_id = var.worker_flavor_id

  public_key_pair = module.bootstrap.public_key_pair_name
  private_key_pair = var.private_key_pair_path
  ssh_login_name  = var.ssh_login_name

  security_groups = [
    module.security_groups.ssh_name,
    module.security_groups.control_plane_api_name,
    module.security_groups.controller_name,
    module.security_groups.worker_name
  ]

  network = {
    name             = module.network.name
    floating_ip_pool = var.network_floating_ip_pool
  }

  user_data = data.cloudinit_config.lb.rendered

  depends_on = [module.bootstrap, module.network, module.security_groups, module.worker, module.control_plane]
}

module "k0s-cluster" {
  source = "./modules/k0s-cluster"

  private_key_pair_path = var.private_key_pair_path
  ssh_login_name = var.ssh_login_name
  hosts = concat(
    [for instance in module.control_plane : {
      role                = "controller"
      private_ip_address  = instance.access_ip_v4
      floating_ip_address = instance.floating_ip_address
    }],
    [for instance in module.worker : {
      role                = "worker"
      private_ip_address  = instance.access_ip_v4
      floating_ip_address = instance.floating_ip_address
    }]
  )

  load_balancer_ip = module.load_balancer[0].floating_ip_address

  depends_on = [module.bootstrap, module.network, module.security_groups, module.control_plane, module.worker, module.load_balancer]
}

module "k0s-crio" {
  source = "./modules/k0s-crio"

  hosts = [ for instance in module.worker : {
    floating_ip_address = instance.floating_ip_address
  }]

  ssh_login_name = var.ssh_login_name
  private_key_pair_path = var.private_key_pair_path

  depends_on = [module.k0s-cluster]
}

module "flux-bootstrap" {
  source = "./modules/flux-bootstrap"

  cluster_config = module.k0s-cluster.kubeconfig
}

module "os-cloud-secret" {
  source = "./modules/os-cloud-secret"

  openstack_auth_url         = var.openstack_auth_url
  cluster_config             = module.k0s-cluster.kubeconfig
  network_external_id        = var.network_external_id
  network_internal_subnet_id = module.network.subnet_id
}

resource "null_resource" "this" {
  provisioner "local-exec" {
    command = "./files/scripts/finalize.sh"
  }

  depends_on = [module.os-cloud-secret]
}
