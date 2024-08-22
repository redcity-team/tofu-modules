variable "name" {
  type = string
}

variable "dns_domain" {
  type    = string
  default = ""
}

variable "router_id" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr = string
    dhcp_pools = optional(list(object({
      start = string
      end   = string
    })), [])
  }))
}
