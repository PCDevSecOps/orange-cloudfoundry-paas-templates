#====================================================================
#  access security group
#====================================================================
resource "openstack_networking_secgroup_v2" "tf-osb-sg" {
  name        = "tf-osb-sg"
  description = "Osb service access security group"
  region      = "${var.region_name}"
}

#--- rule for cloudfoundry-mysql-osb
resource "openstack_networking_secgroup_rule_v2" "tf-osb-sg-cloudfoundry-mysql-osb-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_ip_prefix  = "${var.osb_shared_cidr}"
  security_group_id = "${openstack_networking_secgroup_v2.tf-osb-sg.id}"
}

#--- rule for cf-redis-osb
resource "openstack_networking_secgroup_rule_v2" "tf-osb-sg-cf-redis-osb-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6379
  port_range_max    = 6379
  remote_ip_prefix  = "${var.osb_shared_cidr}"
  security_group_id = "${openstack_networking_secgroup_v2.tf-osb-sg.id}"
}