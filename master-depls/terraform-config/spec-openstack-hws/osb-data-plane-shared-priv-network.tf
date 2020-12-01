#--- osb data plane shared private network
resource "openstack_networking_network_v2" "tf-net-osb-data-plane-shared-priv" {
  name = "tf-net-osb-data-plane-shared-priv"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-osb-data-plane-shared-priv-subnet" {
  name = "tf-net-osb-data-plane-shared-priv-subnet"
  network_id = "${openstack_networking_network_v2.tf-net-osb-data-plane-shared-priv.id}"
  cidr = "192.168.60.0/24"
  gateway_ip = "192.168.60.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
    start = "192.168.60.2"
    end = "192.168.60.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-osb-data-plane-shared-priv-router-interface" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-data-plane-shared-priv-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-osb-data-plane-shared-priv" {
  type       = "value"
  name       = "/tf/networks_net-osb-data-plane-shared-priv"
  data_value = "${openstack_networking_network_v2.tf-net-osb-data-plane-shared-priv.id}"
}
