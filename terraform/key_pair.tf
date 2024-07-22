resource "openstack_compute_keypair_v2" "test-keypair" {
  name       = "test-keypair"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAW3LZKabsT/uM6p5H6pYK6dYZXk8hT9lYOB/85Wo+2r please@dont-use"
}
