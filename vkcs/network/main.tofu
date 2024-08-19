resource "vkcs_networking_network" "this" {
  name               = var.name
  private_dns_domain = var.dns_domain
}

resource "vkcs_networking_subnet" "this" {
  for_each = var.subnets

  name       = each.value.name
  network_id = vkcs_networking_network.this.id
  cidr       = each.value.cidr
}

resource "vkcs_networking_router_interface" "this" {
  for_each = vkcs_networking_subnet.this

  router_id = var.router_id
  subnet_id = each.value.id
}
