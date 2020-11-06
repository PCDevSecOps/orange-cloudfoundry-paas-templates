#--- Internet isolation segment
resource "openstack_networking_network_v2" "tf-is-net" {
  name = "tf-is-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-is-subnet" {
  name = "tf-is-subnet"
  network_id = "${openstack_networking_network_v2.tf-is-net.id}"
  cidr = "192.168.37.0/24"
  gateway_ip = "192.168.37.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
     start = "192.168.37.2"
     end = "192.168.37.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-is-router-interface" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-is-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values

resource "credhub_generic" "openstack_networks_net-is-internet" {
  type       = "value"
  name       = "/tf/networks_net-is-internet"
  data_value = "${openstack_networking_network_v2.tf-is-net.id}"
}