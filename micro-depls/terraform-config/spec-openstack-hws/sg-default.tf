#--- Default security group for bosh instances
resource "openstack_networking_secgroup_v2" "tf-default-sg" {
  name        = "tf-default-sg"
  description = "Default security group for bosh instances"
  region      = "${var.region_name}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-default-sg-rule01" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = "${openstack_networking_secgroup_v2.tf-default-sg.id}"
  security_group_id = "${openstack_networking_secgroup_v2.tf-default-sg.id}"
}

#--- Relaxed security group, enable 192.x traffic from remote regions (as routed by wireguard vpn)
resource "openstack_networking_secgroup_rule_v2" "tf-default-sg-rule02" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "192.168.0.0/16"
  security_group_id = "${openstack_networking_secgroup_v2.tf-default-sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-default-sg-rule03" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  remote_ip_prefix  = "192.168.0.0/16"
  security_group_id = "${openstack_networking_secgroup_v2.tf-default-sg.id}"
}