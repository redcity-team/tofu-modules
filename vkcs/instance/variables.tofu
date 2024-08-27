variable "name" {
  description = "Name of compute instance."
  type        = string
}

variable "name_prefix" {
  description = "The prefix used for naming resources."
  type        = string
  default     = ""
}

variable "flavor_name" {
  description = "The name of the desired flavor for the server."
  type        = string
  default     = "STD2-1-1"
}

variable "availability_zone" {
  description = "The VKCS availability zone in which to create the server."
  type        = string
  default     = "MS1"
}

variable "user_data" {
  description = "The user data to provide when launching the instance."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Map of tags that will be added to created resources."
  type        = set(string)
  default     = []
}

variable "root_volume" {
  description = "The instance root volume block device configuration."
  type = object({
    size     = optional(number, 10)
    type     = optional(string, "ceph-hdd")
    image_id = string
  })
}

variable "block_devices" {
  description = "The additional block device configuration to attach to instance."
  type = map(object({
    size    = number
    type    = optional(string, "ceph-hdd")
    persist = optional(bool, true)
  }))
  default = {}
}

variable "network_ports" {
  description = "The network port configuration to attach to instance."
  type = map(object({
    subnet_id          = string
    ip_address         = optional(string)
    floating_ip        = optional(string)
    security_group_ids = set(string)
  }))
}

variable "network_config" {
  description = "The override network configuration for the instance."
  type        = string
  default     = null
}

variable "ansible_groups" {
  type    = list(string)
  default = []
}
