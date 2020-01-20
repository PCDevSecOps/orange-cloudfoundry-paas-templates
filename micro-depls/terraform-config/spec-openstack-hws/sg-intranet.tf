#--- Intranet https access security group
resource "openstack_networking_secgroup_v2" "tf-intranet-http-sg" {
  name        = "tf-intranet-http-sg"
  description = "Intranet http security group"
  region      = "${var.region_name}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-intranet-http-sg-rule01" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf-intranet-http-sg.id}"
}
resource "openstack_networking_secgroup_rule_v2" "tf-intranet-http-sg-rule02" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf-intranet-http-sg.id}"
}

#--- Intranet https access security group
resource "openstack_networking_secgroup_v2" "tf-intranet-https-sg" {
  name        = "tf-intranet-https-sg"
  description = "Intranet https security group"
  region      = "${var.region_name}"
}

resource "openstack_networking_secgroup_rule_v2" "tf-intranet-https-sg-rule01" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf-intranet-https-sg.id}"
}
