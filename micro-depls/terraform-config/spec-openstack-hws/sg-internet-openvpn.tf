#====================================================================
# Internet openvpn access security group
#====================================================================
resource "openstack_networking_secgroup_v2" "tf-internet-openvpn-sg" {
  name        = "tf-internet-openvpn-sg"
  description = "Internet openvpn access security group"
  region      = "${var.region_name}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-internet-openvpn-sg-rule01" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1194
  port_range_max    = 1194
  remote_ip_prefix  = "${var.openvpn_clients_cidr}"
  security_group_id = "${openstack_networking_secgroup_v2.tf-internet-openvpn-sg.id}"
}
