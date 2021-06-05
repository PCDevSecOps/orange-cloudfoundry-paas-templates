resource "openstack_networking_port_v2" "tf-proxy-cloudfoundry-mysql-port" {
  name           = "tf-proxy-cloudfoundry-mysql-port"
  region = "${var.region_name}"  
  network_id     = "${openstack_networking_network_v2.tf-services.id}"
  admin_state_up = "true"
  
  fixed_ip {
  	subnet_id = "${openstack_networking_subnet_v2.tf-services-subnet.id}"
  	ip_address = "192.168.30.245"
  }
  
}


