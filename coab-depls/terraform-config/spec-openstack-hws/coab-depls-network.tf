#--------------------------------------------
# Coab deployments dedicated compilation network
#--------------------------------------------
resource "openstack_networking_network_v2" "tf-net-coab-depls-compilation" {
  name           = "tf-net-coab-depls-compilation"
  region         = "${data.credhub_value.openstack_region.value}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-coab-depls-compilation-subnet" {
  name       = "tf-net-coab-depls-compilation-subnet"
  region     = "${data.credhub_value.openstack_region.value}"
  network_id = "${openstack_networking_network_v2.tf-net-coab-depls-compilation.id}"
  cidr       = "192.168.210.0/24"
  gateway_ip = "192.168.210.1"
  ip_version = 4

  enable_dhcp = "true"

  allocation_pools {
    start = "192.168.210.2"
    end   = "192.168.210.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-coab-depls-compilation-router-interface" {
  region    = "${data.credhub_value.openstack_region.value}"
  router_id = "${data.credhub_value.openstack_router_id.value}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-coab-depls-compilation-subnet.id}"
}

#outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values

resource "credhub_generic" "openstack_networks_net-coab-depls-compilation" {
  type       = "value"
  name       = "/tf/networks_net-coab-depls-compilation"
  data_value = "${openstack_networking_network_v2.tf-net-coab-depls-compilation.id}"
}

#--------------------------------------------
# Coab deployments dedicated instance network
#--------------------------------------------
resource "openstack_networking_network_v2" "tf-net-coab-depls-instance" {
  name           = "tf-net-coab-depls-instance"
  region         = "${data.credhub_value.openstack_region.value}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-coab-depls-instance-subnet" {
  name       = "tf-net-coab-depls-instance-subnet"
  region     = "${data.credhub_value.openstack_region.value}"
  network_id = "${openstack_networking_network_v2.tf-net-coab-depls-instance.id}"
  cidr       = "192.168.211.0/24"
  gateway_ip = "192.168.211.1"
  ip_version = 4

  enable_dhcp = "true"

  allocation_pools {
    start = "192.168.211.2"
    end   = "192.168.211.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-coab-depls-instance-router-interface" {
  region    = "${data.credhub_value.openstack_region.value}"
  router_id = "${data.credhub_value.openstack_router_id.value}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-coab-depls-instance-subnet.id}"
}

#outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values

resource "credhub_generic" "openstack_networks_net-coab-depls-instance" {
  type       = "value"
  name       = "/tf/networks_net-coab-depls-instance"
  data_value = "${openstack_networking_network_v2.tf-net-coab-depls-instance.id}"
}