#--- Inter Tenant VPN Interco network
resource "openstack_networking_network_v2" "tf-vpn-interco-net" {
  name = "tf-vpn-interco-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-vpn-interco-subnet" {
  name = "tf-vpn-interco-subnet"
  network_id = "${openstack_networking_network_v2.tf-vpn-interco-net.id}"
  cidr = "172.24.99.0/24"
  gateway_ip = "172.24.99.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
     start = "172.24.99.2"
     end = "172.24.99.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-vpn-interco-router-interface" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-vpn-interco-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace vpn-interco used, to separate credhub-seeder injected and terraform injected values

resource "credhub_generic" "openstack_networks_net-vpn-interco" {
  type       = "value"
  name       = "/tf/networks_net-vpn-interco"
  data_value = "${openstack_networking_network_v2.tf-vpn-interco-net.id}"
}