variable "workers" {
  description = "Number of worker nodes"
  default     = 2
  type        = number
}

variable "worker-flavor" {
  description = "Flavor for worker nodes"
  default     = "a1-ram2-disk20-perf1"
  type        = string
}

variable "control-planes" {
  description = "Number of control plan nodes"
  default     = 2
  type        = number
}

variable "control-plane-flavor" {
  description = "Flavor for control plane nodes"
  default     = "a1-ram2-disk20-perf1"
  type        = string
}

variable "load-balancers" {
  description = "Number of load balancers"
  default     = 1
  type        = number
}

variable "load-balancer-flavor" {
  description = "Flavor for load balancers"
  default     = "a1-ram2-disk20-perf1"
  type        = string
}
