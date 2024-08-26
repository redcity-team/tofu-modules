data "vkcs_networking_subnet" "this" {
  for_each = var.network_ports

  subnet_id = each.value.subnet_id
}

resource "vkcs_networking_port" "this" {
  for_each = var.network_ports

  name       = var.name_prefix != "" ? "${var.name_prefix}-${var.name}-${each.key}" : "${var.name}-${each.key}"
  network_id = data.vkcs_networking_subnet.this[each.key].network_id
  fixed_ip {
    subnet_id  = each.value.subnet_id
    ip_address = each.value.ip_address
  }
  full_security_groups_control = true
  security_group_ids           = each.value.security_group_ids
}

resource "vkcs_blockstorage_volume" "this" {
  for_each = {
    for name, block_device in var.block_devices : name => block_device if block_device.persist
  }

  availability_zone = var.availability_zone
  name              = var.name_prefix != "" ? "${var.name_prefix}-${var.name}-${each.key}" : "${var.name}-${each.key}"
  size              = each.value.size
  volume_type       = each.value.type
}

resource "vkcs_compute_floatingip_associate" "this" {
  for_each = {
    for name, port in var.network_ports : name => port if port.floating_ip != null
  }

  floating_ip = each.value.floating_ip
  instance_id = vkcs_compute_instance.this.id
  fixed_ip    = vkcs_networking_port.this[each.key].all_fixed_ips[0]
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
    for_each = var.block_devices
    content {
      source_type           = block_device.value.persist ? "volume" : "blank"
      destination_type      = "volume"
      delete_on_termination = !block_device.value.persist
      volume_size           = !block_device.value.persist ? block_device.value.size : null
      volume_type           = !block_device.value.persist ? block_device.value.type : null
      uuid                  = block_device.value.persist ? vkcs_blockstorage_volume.this[block_device.key].id : null
    }
  }
  dynamic "network" {
    for_each = vkcs_networking_port.this
    content {
      port = vkcs_networking_port.this[network.key].id
    }
  }
  user_data           = var.user_data
  tags                = var.tags
  stop_before_destroy = true
}
