resource "openstack_networking_secgroup_v2" "tf-enable-from-bosh-agents" {
  name        = "tf-enable-from-bosh-agents"
  description = "Enables inbound from bosh agents "
  region      = "${var.region_name}"
}

#enable bosh nats
resource "openstack_networking_secgroup_rule_v2" "tf-enable-from-bosh-agents-rule01" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf-enable-from-bosh-agents.id}"
}

#enable bosh registry
resource "openstack_networking_secgroup_rule_v2" "tf-enable-from-bosh-agents-rule02" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf-enable-from-bosh-agents.id}"
}

