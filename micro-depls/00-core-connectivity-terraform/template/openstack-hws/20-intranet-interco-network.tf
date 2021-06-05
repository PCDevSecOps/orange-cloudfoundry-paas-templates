#--- Setup intranet interco network
resource "openstack_networking_network_v2" "tf_net_intranet_interco_r1" {
  name       = "tf_net_intranet_interco_r1"
  region     = var.openstack_region_name
  admin_state_up = "true"
}

#--- Setup intranet interco subnet
variable "multi_region_region_1_intranet_interco_range" {}
variable "multi_region_region_1_intranet_interco_gateway" {}

resource "openstack_networking_subnet_v2" "tf_subnet_intranet_interco_r1" {
  name       = "tf_subnet_intranet_interco_r1"
  region     = var.openstack_region_name
  network_id = openstack_networking_network_v2.tf_net_intranet_interco_r1.id
  cidr       = var.multi_region_region_1_intranet_interco_range
  gateway_ip = var.multi_region_region_1_intranet_interco_gateway
  ip_version = 4
}

#--- Setup intranet interco router interface
resource "openstack_networking_router_interface_v2" "tf_router_interface_intranet_interco_r1" {
  region    = var.openstack_region_name
  router_id = var.openstack_router_id
  subnet_id = openstack_networking_subnet_v2.tf_subnet_intranet_interco_r1.id
}

#--- Output generated network id (saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
# resource "credhub_generic" "openstack_networks_tf_net_intranet_interco" {
#   type       = "value"
#   name       = "/tf/networks_intranet-interco-r1"
#   data_value = openstack_networking_network_v2.tf_net_intranet_interco_r1.id
# }