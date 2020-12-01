#openstack network for iaas level marketplace endpoints
resource "openstack_networking_network_v2" "tf-net-osb-data-plane-shared-pub" {
  name = "tf-net-osb-data-plane-shared-pub"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-osb-data-plane-shared-pub-subnet" {
  name = "tf-net-osb-data-plane-shared-pub-subnet"
  network_id = "${openstack_networking_network_v2.tf-net-osb-data-plane-shared-pub.id}"
  cidr = "${var.osb_shared_cidr}"
  gateway_ip = "${var.osb_shared_gateway_ip}"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
     start = "${var.osb_shared_dhcp_start}"
     end = "${var.osb_shared_dhcp_end}"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-osb-data-plane-shared-pub-router-interface" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-data-plane-shared-pub-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-osb-data-plane-shared-pub" {
  type       = "value"
  name       = "/tf/networks_net-osb-data-plane-shared-pub"
  data_value = "${openstack_networking_network_v2.tf-net-osb-data-plane-shared-pub.id}"
 }
