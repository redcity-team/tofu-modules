data "vkcs_networking_subnet" "this" {
  count = length(var.network_ports)

  subnet_id = var.network_ports[count.index].subnet_id
}

resource "vkcs_networking_port" "this" {
  count = length(var.network_ports)

  name       = var.name_prefix != "" ? "${var.name_prefix}-${var.network_ports[count.index].name}" : var.network_ports[count.index].name
  network_id = data.vkcs_networking_subnet.this[count.index].network_id
  fixed_ip {
    subnet_id  = var.network_ports[count.index].subnet_id
    ip_address = var.network_ports[count.index].ip_address
  }
  full_security_groups_control = true
  security_group_ids           = var.network_ports[count.index].security_group_ids
}

resource "vkcs_blockstorage_volume" "this" {
  count = length(var.block_devices)

  availability_zone = var.availability_zone
  name              = var.name_prefix != "" ? "${var.name_prefix}-${var.block_devices[count.index].name}" : var.block_devices[count.index].name
  size              = var.block_devices[count.index].size
  volume_type       = var.block_devices[count.index].type
}

resource "vkcs_compute_floatingip_associate" "this" {
  for_each = {
    for port in var.network_ports : index(var.network_ports, port) => port.floating_ip if port.floating_ip != null
  }

  floating_ip = each.value
  instance_id = vkcs_compute_instance.this.id
  fixed_ip    = vkcs_compute_instance.this.network[each.key].fixed_ip_v4
}

resource "ansible_host" "this" {
  name   = var.name
  groups = var.ansible_groups
}

resource "vkcs_compute_instance" "this" {
  name              = var.name_prefix != "" ? "${var.name_prefix}-${var.name}" : var.name
  flavor_name       = var.flavor_name
  availability_zone = var.availability_zone
  block_device {
    boot_index            = 0
    source_type           = "image"
    destination_type      = "volume"
    uuid                  = var.root_volume.image_id
    volume_size           = var.root_volume.size
    volume_type           = var.root_volume.type
    delete_on_termination = true
  }
  dynamic "block_device" {
    for_each = var.swap_volume[*]
    content {
      source_type           = "blank"
      destination_type      = "volume"
      delete_on_termination = true
      volume_size           = var.swap_volume.size
      volume_type           = var.swap_volume.type
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
    for_each = vkcs_networking_port.this
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
