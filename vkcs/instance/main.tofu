resource "vkcs_networking_port" "this" {
  count = length(var.network)

  name       = var.network[count.index].port_name
  network_id = var.network_id
  fixed_ip {
    subnet_id = var.network[count.index].subnet_id
  }
  full_security_groups_control = true
  security_group_ids           = var.network[count.index].security_group_ids
}

resource "vkcs_blockstorage_volume" "this" {
  count = length(var.block_device)

  availability_zone = var.availability_zone
  name              = var.block_device[count.index].name
  size              = var.block_device[count.index].size
  volume_type       = var.block_device[count.index].type
}

resource "vkcs_compute_floatingip_associate" "this" {
  count = length(var.floating_ip)

  floating_ip = var.floating_ip[count.index].address
  instance_id = vkcs_compute_instance.this.id
  fixed_ip    = vkcs_compute_instance.this.network[var.floating_ip[count.index].port].fixed_ip_v4
}

resource "ansible_host" "this" {
  name   = trimprefix (var.name, "redcity-dev-")
  groups = var.ansible_groups
}

resource "vkcs_compute_instance" "this" {
  name              = var.name
  flavor_name       = var.flavor_name
  availability_zone = var.availability_zone
  block_device {
    boot_index            = 0
    source_type           = "image"
    destination_type      = "volume"
    uuid                  = var.root_image_id
    volume_size           = var.root_volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }
  dynamic "block_device" {
    for_each = var.swap_volume_size[*]
    content {
      source_type           = "blank"
      destination_type      = "volume"
      delete_on_termination = true
      volume_size           = var.swap_volume_size
      volume_type           = var.volume_type
    }
  }
  dynamic "block_device" {
    for_each = vkcs_blockstorage_volume.this
    content {
      source_type      = "volume"
      destination_type = "volume"
      uuid             = vkcs_blockstorage_volume.this[block_device.key].id
    }
  }
  dynamic "network" {
    for_each = var.network
    content {
      port = vkcs_networking_port.this[network.key].id
    }
  }
  config_drive = length(var.personality) != 0 ? true : null
  dynamic "personality" {
    for_each = var.personality
    content {
      file    = personality.value.file
      content = personality.value.content
    }
  }
  user_data           = var.user_data
  tags                = var.tags
  stop_before_destroy = true
}
