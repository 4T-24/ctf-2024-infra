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
  user_data = <<-EOL
    #!/bin/bash
    export CRIO_VERSION=v1.29

    apt-get update
    apt-get install -y software-properties-common curl
    apt-get install -y linux-headers-$(uname -r)

    curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
        gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

    echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
        tee /etc/apt/sources.list.d/cri-o.list

    apt-get update
    apt-get install -y cri-o

    systemctl start crio.service

    swapoff -a
    modprobe br_netfilter
    sysctl -w net.ipv4.ip_forward=1
  EOL
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
}
