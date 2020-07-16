resource "openstack_networking_network_v2" "tf-net-cf" {
  name = "tf-net-cf"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-cf-subnet" {
  name = "tf-net-cf-subnet"
  network_id = "${openstack_networking_network_v2.tf-net-cf.id}"
  cidr = "192.168.35.0/24"
  gateway_ip = "192.168.35.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
     start = "192.168.35.2"
     end = "192.168.35.20"
  }

}

resource "openstack_networking_router_interface_v2" "tf-net-cf-router-interface" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-cf-subnet.id}"
}

#outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values

resource "credhub_generic" "openstack_networks_net-cf" {
  type       = "value"
  name       = "/tf/networks_net-cf"
  data_value = "${openstack_networking_network_v2.tf-net-cf.id}"
}