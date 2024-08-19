variable "name" {
  type = string
}

variable "dns_domain" {
  type = string
}

variable "router_id" {
  type = string
}

variable "subnets" {
  type = map(object({
    name = string
    cidr = string
  }))
}
