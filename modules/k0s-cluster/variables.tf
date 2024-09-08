variable "hosts" {
  description = "List of hosts to deploy k0s cluster on"
  type = list(object({
    role                = string
    private_ip_address  = string
    floating_ip_address = string
    install_flags       = list(string)
  }))
}

variable "ssh_login_name" {
  description = "SSH user to connect to hosts"
}

variable "private_key_pair_path" {
  description = "Path to the private key used for SSH access"
}

variable "load_balancer_ip" {
  description = "Load balancer to use for the cluster"
}