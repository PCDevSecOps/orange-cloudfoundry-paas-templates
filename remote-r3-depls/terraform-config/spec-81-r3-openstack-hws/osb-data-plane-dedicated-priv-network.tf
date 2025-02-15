#--- Set osb data plane dedicated private network
resource "openstack_networking_network_v2" "tf-net-osb-data-plane-dedicated-priv-r3" {
  name = "tf-net-osb-data-plane-dedicated-priv-r3"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-osb-data-plane-dedicated-priv-r3-subnet" {
  name       = "tf-net-osb-data-plane-dedicated-priv-r3-subnet"
  network_id = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-r3.id}"
  cidr       = "192.168.68.0/24"
  gateway_ip = "192.168.68.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pool {
    start = "192.168.68.2"
    end   = "192.168.68.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-osb-data-plane-dedicated-priv-r3-router-interface" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-data-plane-dedicated-priv-r3-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-osb-data-plane-dedicated-priv" {
  type       = "value"
  name       = "/tf/networks_net-osb-data-plane-dedicated-priv-r3"
  data_value = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-r3.id}"
}