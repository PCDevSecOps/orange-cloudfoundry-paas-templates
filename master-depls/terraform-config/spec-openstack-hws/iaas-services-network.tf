#openstack network for iaas level marketplace endpoints
resource "openstack_networking_network_v2" "tf-net-iaas-services" {
  name = "tf-net-iaas-services"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-iaas-services-subnet" {
  name = "tf-net-iaas-services-subnet"
  network_id = "${openstack_networking_network_v2.tf-net-iaas-services.id}"
  cidr = "172.24.1.0/24"
  gateway_ip = "172.24.1.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
     start = "172.24.1.2"
     end = "172.24.1.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-iaas-services-router-interface" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-iaas-services-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-iaas-services" {
  type       = "value"
  name       = "/tf/openstack_networks_net-iaas-services"
  data_value = "${openstack_networking_network_v2.tf-net-iaas-services.id}"
 }
