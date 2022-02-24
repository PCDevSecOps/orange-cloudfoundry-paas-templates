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
  allocation_pool {
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

#----------------------------------------------------------
#--- osb data plane dedicated private extension network (3)
#----------------------------------------------------------
resource "openstack_networking_network_v2" "tf-net-osb-data-plane-dedicated-priv-extension-3" {
  name = "tf-net-osb-data-plane-dedicated-priv-extension-3"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-osb-data-plane-dedicated-priv-extension-subnet-3" {
  name = "tf-net-osb-data-plane-dedicated-priv-extension-subnet-3"
  network_id = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-extension-3.id}"
  cidr = "192.168.73.0/24"
  gateway_ip = "192.168.73.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
    start = "192.168.73.2"
    end = "192.168.73.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-osb-data-plane-dedicated-priv-extension-router-interface-3" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-data-plane-dedicated-priv-extension-subnet-3.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-osb-data-plane-dedicated-priv-extension-3" {
  type       = "value"
  name       = "/tf/networks_net-osb-data-plane-dedicated-priv-extension-3"
  data_value = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-extension-3.id}"
}

#----------------------------------------------------------
#--- osb data plane dedicated private extension network (4)
#----------------------------------------------------------
resource "openstack_networking_network_v2" "tf-net-osb-data-plane-dedicated-priv-extension-4" {
  name = "tf-net-osb-data-plane-dedicated-priv-extension-4"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-osb-data-plane-dedicated-priv-extension-subnet-4" {
  name = "tf-net-osb-data-plane-dedicated-priv-extension-subnet-4"
  network_id = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-extension-4.id}"
  cidr = "192.168.76.0/24"
  gateway_ip = "192.168.76.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
    start = "192.168.76.2"
    end = "192.168.76.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-osb-data-plane-dedicated-priv-extension-router-interface-4" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-data-plane-dedicated-priv-extension-subnet-4.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-osb-data-plane-dedicated-priv-extension-4" {
  type = "value"
  name = "/tf/networks_net-osb-data-plane-dedicated-priv-extension-4"
  data_value = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-extension-4.id}"
}

#----------------------------------------------------------
#--- osb data plane dedicated private extension network (5)
#----------------------------------------------------------
resource "openstack_networking_network_v2" "tf-net-osb-data-plane-dedicated-priv-extension-5" {
  name = "tf-net-osb-data-plane-dedicated-priv-extension-5"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-osb-data-plane-dedicated-priv-extension-subnet-5" {
  name = "tf-net-osb-data-plane-dedicated-priv-extension-subnet-5"
  network_id = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-extension-5.id}"
  cidr = "192.168.77.0/24"
  gateway_ip = "192.168.77.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
    start = "192.168.77.2"
    end = "192.168.77.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-osb-data-plane-dedicated-priv-extension-router-interface-5" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-data-plane-dedicated-priv-extension-subnet-5.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-osb-data-plane-dedicated-priv-extension-5" {
  type = "value"
  name = "/tf/networks_net-osb-data-plane-dedicated-priv-extension-5"
  data_value = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-priv-extension-5.id}"
}
