#--- osb control plane network
resource "openstack_networking_network_v2" "tf-net-osb-control-plane" {
  name = "tf-net-osb-control-plane"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-osb-control-plane-subnet" {
  name = "tf-net-osb-control-plane-subnet"
  network_id = "${openstack_networking_network_v2.tf-net-osb-control-plane.id}"
  cidr = "192.168.62.0/24"
  gateway_ip = "192.168.62.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
    start = "192.168.62.2"
    end = "192.168.62.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-osb-control-plane-router-interface" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-osb-control-plane-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-osb-control-plane" {
  type       = "value"
  name       = "/tf/networks_net-osb-control-plane"
  data_value = "${openstack_networking_network_v2.tf-net-osb-control-plane.id}"
 }
