output "this" {
  value = vkcs_networking_secgroup.this
}

output "ingress_rules" {
  value = vkcs_networking_secgroup_rule.ingress
}

output "egress_rules" {
  value = vkcs_networking_secgroup_rule.egress
}
