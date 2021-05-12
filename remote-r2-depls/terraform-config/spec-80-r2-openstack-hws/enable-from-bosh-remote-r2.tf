#--- Enable bosh ssh
resource "openstack_networking_secgroup_v2" "tf-enable-from-bosh-r1" {
  name        = "tf-r2-from-remote-bosh"
  description = "Enables inbound from r1, bosh-remote-r2"
  region      = "${data.credhub_value.openstack_region.value}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-enable-from-bosh-r1-rule01" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf-enable-from-bosh-r1.id}"
}