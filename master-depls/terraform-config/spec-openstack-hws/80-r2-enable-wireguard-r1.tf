resource "openstack_networking_secgroup_v2" "tf-enable-wireguard-r1" {
  name        = "tf-enable-wireguard-r1"
  description = "Enables inbound wireguard peer traffic"
  region      = "${var.region_name}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-enable-wireguard-r1-rule01" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf-enable-wireguard-r1.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-enable-wireguard-r1-rule02" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf-enable-wireguard-r1.id}"
}
