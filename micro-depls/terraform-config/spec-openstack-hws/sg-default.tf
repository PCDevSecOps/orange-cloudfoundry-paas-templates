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