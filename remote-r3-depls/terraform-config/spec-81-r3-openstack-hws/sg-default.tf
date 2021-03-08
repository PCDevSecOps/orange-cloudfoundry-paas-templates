#--- Default security group for bosh instances
resource "openstack_networking_secgroup_v2" "tf-default-sg-r3" {
  name        = "tf-default-sg-r3"
  description = "Default security group for bosh instances"
  region      = "${data.credhub_value.openstack_region.value}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-default-sg-r3-rule01" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = "${openstack_networking_secgroup_v2.tf-default-sg-r3.id}"
  security_group_id = "${openstack_networking_secgroup_v2.tf-default-sg-r3.id}"
}

#--Relaxed security group, enable 192.x traffic from remote regions (as routed by wireguard vpn)
resource "openstack_networking_secgroup_rule_v2" "tf-default-sg-r3-rule02" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "192.168.0.0/16"
  security_group_id = "${openstack_networking_secgroup_v2.tf-default-sg-r3.id}"
}
