#--- Set k8s network
resource "openstack_networking_network_v2" "tf-net-kubo" {
  name           = "tf-net-kubo"
  region         = "${data.credhub_value.openstack_region.value}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-kubo-subnet" {
  name        = "tf-net-kubo-subnet"
  region      = "${data.credhub_value.openstack_region.value}"
  network_id  = "${openstack_networking_network_v2.tf-net-kubo.id}"
  cidr        = "192.168.245.0/24"
  gateway_ip  = "192.168.245.1"
  ip_version  = 4
  enable_dhcp = "true"

  allocation_pool {
    start = "192.168.245.2"
    end   = "192.168.245.150"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-kubo-router-interface" {
  region    = "${data.credhub_value.openstack_region.value}"
  router_id = "${data.credhub_value.openstack_router_id.value}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-kubo-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net-kubo" {
  type       = "value"
  name       = "/tf/networks_net-kubo"
  data_value = "${openstack_networking_network_v2.tf-net-kubo.id}"
}