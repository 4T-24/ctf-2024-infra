data "cloudinit_config" "lb" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/files/cloud-init/lb-cloud-init.tftpl.yml", {
      haproxy_config = templatefile("${path.module}/files/configs/haproxy.tftpl.cfg", {
        controllers = [for instance in module.control_plane : {
          name   = instance.access_ip_v4
          addr   = instance.access_ip_v4
        }]
      })
    })
  }

  part {
      filename     = "lb-cloud-init.sh"
      content_type = "text/x-shellscript"

      content = file("${path.module}/files/scripts/lb-cloud-init.sh")
    }
}

data "cloudinit_config" "worker" {
  gzip = false
  base64_encode = false

  part {
      filename     = "worker-cloud-init.sh"
      content_type = "text/x-shellscript"

      content = file("${path.module}/files/scripts/worker-cloud-init.sh")
    }
}
