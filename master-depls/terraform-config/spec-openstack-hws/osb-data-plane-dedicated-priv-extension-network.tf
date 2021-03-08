#--- osb data plane dedicated private extension network
resource "openstack_networking_network_v2" "tf-net-osb-data-plane-dedicated-priv-extension" {
  name = "tf-net-osb-data-plane-dedicated-priv-extension"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-osb-data-plane-dedicated-priv-extension-subnet" {
  name = "tf-net-osb-data-plane-dedicated-priv-extension-subnet"
  network_id = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-extension.id}"
  cidr = "192.168.70.0/24"
  gateway_ip = "192.168.70.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
    start = "192.168.70.2"
    end = "192.168.70.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-osb-data-plane-dedicated-priv-extension-router-interface" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-data-plane-dedicated-priv-extension-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-osb-data-plane-dedicated-priv-extension" {
  type       = "value"
  name       = "/tf/networks_net-osb-data-plane-dedicated-priv-extension"
  data_value = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-extension.id}"
}
