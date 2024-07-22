resource "openstack_compute_instance_v2" "workers" {
  for_each        = toset([for i in range(var.workers) : tostring(i)])
  name            = "worker-${each.key}"
  flavor_name     = var.worker-flavor
  image_name      = "Debian 12 bookworm"
  key_pair        = openstack_compute_keypair_v2.test-keypair.name
  security_groups = ["default", openstack_networking_secgroup_v2.ssh-secgroup.name]
  network {
    name = "ext-net1"
  }
  user_data = data.cloudinit_config.worker-cloud-init.rendered
}

resource "openstack_compute_instance_v2" "control-planes" {
  for_each        = toset([for i in range(var.control-planes) : tostring(i)])
  name            = "controller-${each.key}"
  flavor_name     = var.control-plane-flavor
  image_name      = "Debian 12 bookworm"
  key_pair        = openstack_compute_keypair_v2.test-keypair.name
  security_groups = ["default", openstack_networking_secgroup_v2.ssh-secgroup.name]
  network {
    name = "ext-net1"
  }
}

resource "openstack_compute_instance_v2" "load-balancers" {
  for_each        = toset([for i in range(var.load-balancers) : tostring(i)])
  name            = "lb-${each.key}"
  flavor_name     = var.load-balancer-flavor
  image_name      = "Debian 12 bookworm"
  key_pair        = openstack_compute_keypair_v2.test-keypair.name
  security_groups = ["default", openstack_networking_secgroup_v2.ssh-secgroup.name]
  network {
    name = "ext-net1"
  }
  user_data = data.cloudinit_config.lb-cloud-init.rendered
}
