resource "openstack_networking_network_v2" "tf-net-cfcr-master" {
  name           = "tf-net-cfcr-master"
  region         = "${data.credhub_value.openstack_region.value}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-cfcr-master-subnet" {
  name       = "tf-net-kubo-subnet"
  region     = "${data.credhub_value.openstack_region.value}"
  network_id = "${openstack_networking_network_v2.tf-net-cfcr-master.id}"
  cidr       = "192.168.244.0/24"
  gateway_ip = "192.168.244.1"
  ip_version = 4

  enable_dhcp = "true"

  allocation_pool {
    start = "192.168.244.2"
    end   = "192.168.244.150"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-cfcr-master-router-interface" {
  region    = "${data.credhub_value.openstack_region.value}"
  router_id = "${data.credhub_value.openstack_router_id.value}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-cfcr-master-subnet.id}"
}

#outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values

resource "credhub_generic" "openstack_networks_net_cfcr_master" {
  type       = "value"
  name       = "/tf/networks_net-cfcr-master"
  data_value = "${openstack_networking_network_v2.tf-net-cfcr-master.id}"
}
