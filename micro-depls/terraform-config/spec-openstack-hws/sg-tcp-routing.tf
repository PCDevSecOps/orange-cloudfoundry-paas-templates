#====================================================================
# TCP Routing access security group
#====================================================================
resource "openstack_networking_secgroup_v2" "tf-tcp-routing-sg" {
  name        = "tf-tcp-routing-sg"
  description = "TCP Routing access security group"
  region      = "${var.region_name}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-tcp-routing-sg-rule01" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "${var.default_router_group_reservable_port_min}"
  port_range_max    = "${var.default_router_group_reservable_port_max}"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf-tcp-routing-sg.id}"
}
