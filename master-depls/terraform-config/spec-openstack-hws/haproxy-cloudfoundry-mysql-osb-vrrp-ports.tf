resource "openstack_networking_port_v2" "tf-haproxy-cloudfoundry-mysql-osb-port" {
  name           = "tf-haproxy-cloudfoundry-mysql-osb-port"
  region = "${var.region_name}"  
  network_id     = "${openstack_networking_network_v2.tf-net-osb-data-plane-shared-pub.id}"
  admin_state_up = "true"
  
  fixed_ip {
  	subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-data-plane-shared-pub-subnet.id}"
  	ip_address = "${var.vrrp_ip_cloudfoundry_mysql_osb}"
  }
  
}


