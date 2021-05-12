#--- Get Terraform data
data "openstack_networking_network_v2" "tf_net_intranet_interco_r1" {
  name = "tf_net_intranet_interco_r1"
}

data "openstack_networking_subnet_v2" "tf_subnet_intranet_interco_r1" {
  name = "tf_subnet_intranet_interco_r1"
}

#--- Set api vip port
variable "multi_region_region_1_intranet_interco_api" {}

resource "openstack_networking_port_v2" "tf_intranet_interco_r1_api_vip_port" {
  name = "tf_intranet_interco_r1_api_vip_port"
  region = var.openstack_region_name
  network_id = data.openstack_networking_network_v2.tf_net_intranet_interco_r1.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.tf_subnet_intranet_interco_r1.id
    ip_address = var.multi_region_region_1_intranet_interco_api
  }
}

#--- Set apps vip port
variable "multi_region_region_1_intranet_interco_apps" {}

resource "openstack_networking_port_v2" "tf_intranet_interco_r1_apps_vip_port" {
  name = "tf_intranet_interco_r1_apps_vip_port"
  region = var.openstack_region_name
  network_id = data.openstack_networking_network_v2.tf_net_intranet_interco_r1.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.tf_subnet_intranet_interco_r1.id
    ip_address = var.multi_region_region_1_intranet_interco_apps
  }
}

#--- Set ops vip port
variable "multi_region_region_1_intranet_interco_ops" {}

resource "openstack_networking_port_v2" "tf_intranet_interco_r1_ops_vip_port" {
  name = "tf_intranet_interco_r1_ops_vip_port"
  region = var.openstack_region_name
  network_id = data.openstack_networking_network_v2.tf_net_intranet_interco_r1.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.tf_subnet_intranet_interco_r1.id
    ip_address = var.multi_region_region_1_intranet_interco_ops
  }
}

#--- Set osb vip port
variable "multi_region_region_1_intranet_interco_osb" {}

resource "openstack_networking_port_v2" "tf_intranet_interco_r1_osb_vip_port" {
  name = "tf_intranet_interco_r1_osb_vip_port"
  region = var.openstack_region_name
  network_id = data.openstack_networking_network_v2.tf_net_intranet_interco_r1.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.tf_subnet_intranet_interco_r1.id
    ip_address = var.multi_region_region_1_intranet_interco_osb
  }
}
