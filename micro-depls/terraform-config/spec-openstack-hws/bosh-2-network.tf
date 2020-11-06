resource "openstack_networking_network_v2" "tf_net_bosh2" {
  name = "tf_net_bosh2"
  region = "${var.region_name}"  
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_bosh2" {
  name = "subnet_bosh2"
  region = "${var.region_name}"  
  network_id = "${openstack_networking_network_v2.tf_net_bosh2.id}"
  cidr = "192.168.116.0/24"
  gateway_ip = "192.168.116.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
     start = "192.168.116.2"
     end = "192.168.116.20"
  }

}

resource "openstack_networking_router_interface_v2" "tf_router_interface_bosh2" {
 region = "${var.region_name}"
  router_id = "${var.router_id}"
subnet_id = "${openstack_networking_subnet_v2.subnet_bosh2.id}"
}
