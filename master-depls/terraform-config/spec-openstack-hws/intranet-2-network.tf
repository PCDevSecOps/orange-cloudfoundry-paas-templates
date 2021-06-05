#--- Set intranet-2 isolation segment private network
resource "openstack_networking_network_v2" "tf-net-intranet-2" {
  name = "tf-net-intranet-2"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-intranet-2-subnet" {
  name = "tf-net-intranet-2-subnet"
  network_id = "${openstack_networking_network_v2.tf-net-intranet-2.id}"
  cidr = "192.168.29.0/24"
  gateway_ip = "192.168.29.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pool {
     start = "192.168.29.2"
     end = "192.168.29.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-intranet-2-router-interface" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-intranet-2-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-intranet-2" {
  type       = "value"
  name       = "/tf/networks_net-intranet-2"
  data_value = "${openstack_networking_network_v2.tf-net-intranet-2.id}"
}