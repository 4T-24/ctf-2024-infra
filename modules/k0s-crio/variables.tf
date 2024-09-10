variable "hosts" {
  description = "List of hosts to deploy crio"
  type = list(object({
    floating_ip_address = string
  }))
}

variable "ssh_login_name" {
  description = "SSH user to connect to hosts"
}

variable "private_key_pair_path" {
  description = "Path to the private key used for SSH access"
}