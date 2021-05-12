#--- Set default security group for bosh instances
resource "openstack_networking_secgroup_v2" "tf-default-sg-r2" {
  name        = "tf-default-sg-r2"
  description = "Default security group for bosh instances"
  region      = "${data.credhub_value.openstack_region.value}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-default-sg-r2-rule01" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = "${openstack_networking_secgroup_v2.tf-default-sg-r2.id}"
  security_group_id = "${openstack_networking_secgroup_v2.tf-default-sg-r2.id}"
}