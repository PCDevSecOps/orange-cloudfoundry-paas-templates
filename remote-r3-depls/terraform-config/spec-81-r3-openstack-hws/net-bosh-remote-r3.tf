#--- Set bosh-remote-r3 network
resource "openstack_networking_network_v2" "tf_net_bosh_remote_3" {
  name   = "tf_net_bosh_remote_3"
  region = "${data.credhub_value.openstack_region.value}"  
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_bosh_remote_3" {
  name       = "subnet_bosh_remote_3"
  region     = "${data.credhub_value.openstack_region.value}"  
  network_id = "${openstack_networking_network_v2.tf_net_bosh_remote_3.id}"
  cidr       = "192.168.118.0/24"
  gateway_ip = "192.168.118.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pool {
     start = "192.168.118.2"
     end   = "192.168.118.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf_router_interface_bosh_remote_3" {
 region = "${data.credhub_value.openstack_region.value}"
 router_id = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
 subnet_id = "${openstack_networking_subnet_v2.subnet_bosh_remote_3.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_tf_net_bosh-remote-3" {
  type       = "value"
  name       = "/tf/networks_bosh-remote-3"
  data_value = "${openstack_networking_network_v2.tf_net_bosh_remote_3.id}"
}