variable "name" {
  type = string
}

variable "flavor_name" {
  type    = string
  default = "STD2-1-1"
}

variable "availability_zone" {
  type    = string
  default = "MS1"
}

variable "user_data" {
  type    = string
  default = ""
}

variable "tags" {
  type    = set(string)
  default = []
}

variable "block_device" {
  type = list(object({
    name = string
    size = number
    type = string
  }))
  default = []
}

variable "personality" {
  type = list(object({
    file    = string
    content = string
  }))
  default = []
}

variable "volume_type" {
  type    = string
  default = "ceph-hdd"
}

variable "root_volume_size" {
  type    = number
  default = 10
}

variable "swap_volume_size" {
  type    = number
  default = null
}

variable "root_image_id" {
  type = string
}

variable "network_id" {
  type = string
}

variable "network" {
  type = list(object({
    port_name          = string
    subnet_id          = string
    security_group_ids = set(string)
  }))
}

variable "floating_ip" {
  type = list(object({
    address = string
    port    = number
  }))
  default = []
}

variable "ansible_groups" {
  type    = list(string)
  default = []
}
