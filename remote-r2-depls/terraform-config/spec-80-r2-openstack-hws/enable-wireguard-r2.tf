#--- Enable wireguard ssl access
resource "openstack_networking_secgroup_v2" "tf-enable-wireguard-r2" {
  name        = "tf-enable-wireguard-r2"
  description = "Enables inbound wireguard peer traffic"
  region      = "${data.credhub_value.openstack_region.value}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-enable-wireguard-r2-rule01" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf-enable-wireguard-r2.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-enable-wireguard-r2-rule02" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf-enable-wireguard-r2.id}"
}