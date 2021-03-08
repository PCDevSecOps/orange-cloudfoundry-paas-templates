resource "openstack_networking_network_v2" "tf-net-exchange" {
  name = "tf-net-exchange"
  region = "${var.region_name}"  
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-exchange-subnet" {
  name = "tf-net-exchange-subnet"
  region = "${var.region_name}"  
  network_id = "${openstack_networking_network_v2.tf-net-exchange.id}"
  cidr = "192.168.99.0/24"
  gateway_ip = "192.168.99.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
     start = "192.168.99.2"
     end = "192.168.99.20"
  }

}

resource "openstack_networking_router_interface_v2" "tf-net-exchange-router-interface" {
  region = "${var.region_name}"
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-exchange-subnet.id}"
}
