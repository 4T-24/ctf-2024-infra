locals {
  k0s_hosts = [for host in var.hosts : {
    role = host.role
    ssh = {
      address = host.floating_ip_address
      port    = 22
      user    = var.ssh_login_name
      key_path    = var.private_key_pair_path
      install_flags = host.install_flags
    }
  }]
}

resource "k0s_cluster" "this" {
  name    = "k0s.cluster"
  version = "1.29.6+k0s.0"

  hosts = local.k0s_hosts

  config = <<EOT
apiVersion: k0s.k0sproject.io/v1beta1
kind: ClusterConfig
metadata:
  name: k0s
spec:
  api:
    externalAddress: ${var.load_balancer_ip}
    sans: [${var.load_balancer_ip}]
  network:
    podCIDR: 10.244.0.0/16
    serviceCIDR: 10.96.0.0/12
    provider: calico
    calico:
      mode: vxlan
      vxlanPort: 4789
      vxlanVNI: 4096
      mtu: 1450
      wireguard: false
      flexVolumeDriverPath: /usr/libexec/k0s/kubelet-plugins/volume/exec/nodeagent~uds
      withWindowsNodes: false
      overlay: Always
  workerProfiles:
    - name: crio-compatibility
      values:
      cgroupDriver: systemd
  images:
    calico:
      cni:
        image: calico/cni
        version: v3.16.2
      flexvolume:
        image: calico/pod2daemon-flexvol
        version: v3.16.2
      node:
        image: calico/node
        version: v3.16.2
      kubecontrollers:
        image: calico/kube-controllers
        version: v3.16.2
EOT

  # provisioner "local-exec" {
  #   command = "ssh -i ${var.private_key_pair_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o IdentitiesOnly=yes -o ConnectTimeout=10 -o ServerAliveInterval=60 -o ServerAliveCountMax=30 ${var.ssh_login_name}@${var.load_balancer_ip} sudo k0s kubeconfig admin >> kubeconfig"
  # }
}
