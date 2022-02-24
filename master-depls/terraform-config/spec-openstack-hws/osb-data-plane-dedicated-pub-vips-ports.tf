resource "openstack_networking_port_v2" "tf-net-osb-data-plane-dedicated-pub-vip-port" {
  name           = "tf-net-osb-data-plane-dedicated-pub-vip-port"
  network_id     = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-pub.id}"
  admin_state_up = "true"
  
  fixed_ip {
  	subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-data-plane-dedicated-pub-subnet.id}"
  	ip_address = "172.16.32.200"  #FIXME
  }
  
}


