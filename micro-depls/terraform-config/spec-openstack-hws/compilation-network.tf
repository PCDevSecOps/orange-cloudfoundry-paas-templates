resource "openstack_networking_network_v2" "tf_net_compilation" {
  name = "tf_net_compilation"
  region = "${var.region_name}"  
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_compilation" {
  name = "subnet_compilation"
  region = "${var.region_name}"  
  network_id = "${openstack_networking_network_v2.tf_net_compilation.id}"
  cidr = "192.168.100.0/24"
  gateway_ip = "192.168.100.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
     start = "192.168.100.2"
     end = "192.168.100.20"
  }

}

resource "openstack_networking_router_interface_v2" "tf_router_interface_compilation" {
  region = "${var.region_name}"
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_compilation.id}"
}
