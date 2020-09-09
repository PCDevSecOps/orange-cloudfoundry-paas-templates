resource "openstack_networking_port_v2" "tf-logsearch-ops-port" {
  name           = "tf-logsearch-ops-port"
  region = "${var.region_name}"  
  network_id     = "${openstack_networking_network_v2.tf-net-exchange.id}"
  admin_state_up = "true"
  
  fixed_ip {
  	subnet_id = "${openstack_networking_subnet_v2.tf-net-exchange-subnet.id}" 
  	ip_address = "192.168.99.245"
  }
  
}


