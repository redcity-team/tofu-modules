resource "vkcs_networking_secgroup" "this" {
  name                 = var.name
  delete_default_rules = true
}

resource "vkcs_networking_secgroup_rule" "ingress" {
  count = length(var.ingress_rules)

  security_group_id = vkcs_networking_secgroup.this.id
  direction         = "ingress"
  protocol          = var.ingress_rules[count.index].protocol
  port_range_min    = var.ingress_rules[count.index].port_range_min
  port_range_max    = var.ingress_rules[count.index].port_range_max
  remote_group_id   = var.ingress_rules[count.index].remote_group_id
  remote_ip_prefix  = var.ingress_rules[count.index].remote_ip_prefix
}

resource "vkcs_networking_secgroup_rule" "egress" {
  count = length(var.egress_rules)

  security_group_id = vkcs_networking_secgroup.this.id
  direction         = "egress"
  protocol          = var.egress_rules[count.index].protocol
  port_range_min    = var.egress_rules[count.index].port_range_min
  port_range_max    = var.egress_rules[count.index].port_range_max
  remote_group_id   = var.egress_rules[count.index].remote_group_id
  remote_ip_prefix  = var.egress_rules[count.index].remote_ip_prefix
}
