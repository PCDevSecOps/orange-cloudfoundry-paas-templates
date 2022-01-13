resource "openstack_networking_port_v2" "intranet-smtp-vip-port" {
  name = "tf-intranet-smtp-vip-port"
  region = var.openstack_region_name  
  network_id = data.openstack_networking_network_v2.tf_net_bosh2.id
  admin_state_up = "true"

  fixed_ip {
  	subnet_id = data.openstack_networking_subnet_v2.subnet_bosh2.id
  	ip_address = "192.168.116.13"
  }
}

