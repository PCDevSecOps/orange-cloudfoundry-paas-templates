#--- Set osb data plane dedicated private extension network
resource "openstack_networking_network_v2" "tf-net-osb-data-plane-dedicated-priv-extension-r3" {
  name = "tf-net-osb-data-plane-dedicated-priv-extension-r3"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-osb-data-plane-dedicated-priv-extension-r3-subnet" {
  name       = "tf-net-osb-data-plane-dedicated-priv-extension-r3-subnet"
  network_id = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-extension-r3.id}"
  cidr       = "192.168.72.0/24"
  gateway_ip = "192.168.72.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pool {
    start = "192.168.72.2"
    end   = "192.168.72.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-osb-data-plane-dedicated-priv-extension-r3-router-interface" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-data-plane-dedicated-priv-extension-r3-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-osb-data-plane-dedicated-priv-extension-r3" {
  type       = "value"
  name       = "/tf/networks_net-osb-data-plane-dedicated-priv-extension-r3"
  data_value = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-extension-r3.id}"
}

#----------------------------------------------------------
#--- osb data plane dedicated private extension network (3)
#----------------------------------------------------------
resource "openstack_networking_network_v2" "tf-net-osb-data-plane-dedicated-priv-extension-r3-3" {
  name = "tf-net-osb-data-plane-dedicated-priv-extension-r3-3"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-osb-data-plane-dedicated-priv-extension-r3-subnet-3" {
  name = "tf-net-osb-data-plane-dedicated-priv-extension-r3-subnet-3"
  network_id = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-extension-r3-3.id}"
  cidr = "192.168.75.0/24"
  gateway_ip = "192.168.75.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
    start = "192.168.75.2"
    end = "192.168.75.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-osb-data-plane-dedicated-priv-extension-r3-router-interface-3" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-data-plane-dedicated-priv-extension-r3-subnet-3.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-osb-data-plane-dedicated-priv-extension-r3-3" {
  type       = "value"
  name       = "/tf/networks_net-osb-data-plane-dedicated-priv-extension-r3-3"
  data_value = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-extension-r3-3.id}"
}
