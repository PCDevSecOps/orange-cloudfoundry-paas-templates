#--- Set remote-r2 network
resource "openstack_networking_network_v2" "tf_net_bosh_remote_2" {
  name   = "tf_net_bosh_remote_2"
  region = "${data.credhub_value.openstack_region.value}"  
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_bosh_remote_2" {
  name       = "subnet_bosh_remote_2"
  region     = "${data.credhub_value.openstack_region.value}"  
  network_id = "${openstack_networking_network_v2.tf_net_bosh_remote_2.id}"
  cidr       = "192.168.117.0/24"
  gateway_ip = "192.168.117.1"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pool {
     start = "192.168.117.2"
     end   = "192.168.117.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf_router_interface_bosh_remote_2" {
 region    = "${data.credhub_value.openstack_region.value}"
 router_id = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
 subnet_id = "${openstack_networking_subnet_v2.subnet_bosh_remote_2.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_tf_net_bosh-remote-2" {
  type       = "value"
  name       = "/tf/networks_bosh-remote-2"
  data_value = "${openstack_networking_network_v2.tf_net_bosh_remote_2.id}"
}