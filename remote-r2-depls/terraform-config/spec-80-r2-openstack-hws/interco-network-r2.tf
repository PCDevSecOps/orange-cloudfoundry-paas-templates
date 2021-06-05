#--- Set intranet interco network
data "credhub_value" "multi_region_region_2_vpn_interco_range" {
  name = "/secrets/multi_region_region_2_vpn_interco_range"
}

data "credhub_value" "multi_region_region_2_vpn_interco_gateway" {
  name = "/secrets/multi_region_region_2_vpn_interco_gateway"
}

resource "openstack_networking_network_v2" "tf_net_interco_remote_2" {
  name = "tf_net_interco_remote_2"
  region = "${data.credhub_value.openstack_region.value}"  
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_interco_remote_2" {
  name       = "subnet_interco_remote_2"
  region     = "${data.credhub_value.openstack_region.value}"  
  network_id = "${openstack_networking_network_v2.tf_net_interco_remote_2.id}"
  cidr       = "${data.credhub_value.multi_region_region_2_vpn_interco_range.value}"
  gateway_ip = "${data.credhub_value.multi_region_region_2_vpn_interco_gateway.value}"
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "tf_router_interface_interco_remote_2" {
 region    = "${data.credhub_value.openstack_region.value}"
 router_id = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
 subnet_id = "${openstack_networking_subnet_v2.subnet_interco_remote_2.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_tf_net_interco-2" {
  type       = "value"
  name       = "/tf/networks_interco-2"
  data_value = "${openstack_networking_network_v2.tf_net_interco_remote_2.id}"
}