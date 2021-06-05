# lookup existing tf-net-bosh-2 network and subnet

resource "openstack_networking_port_v2" "intranet-proxy-vip-port" {
  name = "tf-intranet-proxy-vip-port"
  region = var.openstack_region_name  
  network_id = data.openstack_networking_network_v2.tf_net_bosh2.id
  admin_state_up = "true"

  fixed_ip {
  	subnet_id = data.openstack_networking_subnet_v2.subnet_bosh2.id
  	ip_address = "192.168.116.17"
  }
}

