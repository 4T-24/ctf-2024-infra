resource "null_resource" "this" {
  for_each = { for i, host in var.hosts : i => host }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_login_name
      private_key = file(var.private_key_pair_path)
      host        = each.value["floating_ip_address"]
    }

    inline = [
      "while [ ! -f /etc/systemd/system/k0sworker.service ]; do sleep 2; done",
      "sudo sed -i 's|--kubelet-extra-args=|--cri-socket remote:unix:///var/run/crio/crio.sock --profile crio-compatibility --enable-cloud-provider --kubelet-extra-args=|g' /etc/systemd/system/k0sworker.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart k0sworker",
    ]
  }
}
