variable "name" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    protocol         = optional(string)
    port_range_min   = optional(number)
    port_range_max   = optional(number)
    remote_group_id  = optional(string)
    remote_ip_prefix = optional(string)
  }))
  default = []
}

variable "egress_rules" {
  type = list(object({
    protocol         = optional(string)
    port_range_min   = optional(number)
    port_range_max   = optional(number)
    remote_group_id  = optional(string)
    remote_ip_prefix = optional(string)
  }))
  default = []
}
