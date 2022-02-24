#openstack network for iaas level marketplace endpoints
resource "openstack_networking_network_v2" "tf-net-osb-data-plane-dedicated-pub-extension" {
  name = "tf-net-osb-data-plane-dedicated-pub-extension"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-osb-data-plane-dedicated-pub-extension-subnet" {
  name = "tf-net-osb-data-plane-dedicated-pub-extension-subnet"
  network_id = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-pub-extension.id}"
  cidr = "${var.osb_dedicated_extension_cidr}"
  gateway_ip = "${var.osb_dedicated_extension_gateway_ip}"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pool {
     start = "${var.osb_dedicated_extension_dhcp_start}"
     end = "${var.osb_dedicated_extension_dhcp_end}"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-osb-data-plane-dedicated-pub-extension-router-interface" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-data-plane-dedicated-pub-extension-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-osb-data-plane-dedicated-pub-extension" {
  type       = "value"
  name       = "/tf/networks_net-osb-data-plane-dedicated-pub-extension"
  data_value = "${openstack_networking_network_v2.tf-net-osb-data-plane-dedicated-pub-extension.id}"
 }
