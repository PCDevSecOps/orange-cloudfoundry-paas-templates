#--- "tf-apps-dev" network
resource "openstack_networking_network_v2" "tf-apps-dev" {
  name = "tf-apps-dev"
  region = "${var.region_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-apps-dev-subnet" {
  name = "tf-apps-dev-subnet"
  region = "${var.region_name}"
  network_id = "${openstack_networking_network_v2.tf-apps-dev.id}"
  cidr = "192.168.26.0/24"
  gateway_ip = "192.168.26.254"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
    start = "192.168.26.200"
    end = "192.168.26.210"
  }
}

resource "openstack_networking_router_interface_v2" "tf-apps-dev-router-interface" {
  region = "${var.region_name}"
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-apps-dev-subnet.id}"
}

#--- "tf-services" network
resource "openstack_networking_network_v2" "tf-services" {
  name = "tf-services"
  region = "${var.region_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-services-subnet" {
  name = "tf-services-subnet"
  region = "${var.region_name}"
  network_id = "${openstack_networking_network_v2.tf-services.id}"
  cidr = "192.168.30.0/24"
  gateway_ip = "192.168.30.254"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
    start = "192.168.30.2"
    end = "192.168.30.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-services-router-interface" {
  region = "${var.region_name}"
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-services-subnet.id}"
}

#--- "tf-services-2" network
resource "openstack_networking_network_v2" "tf-services-2" {
  name = "tf-services-2"
  region = "${var.region_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-services-2-subnet" {
  name = "tf-services-2-subnet"
  region = "${var.region_name}"
  network_id = "${openstack_networking_network_v2.tf-services-2.id}"
  cidr = "192.168.31.0/24"
  gateway_ip = "192.168.31.254"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
    start = "192.168.31.2"
    end = "192.168.31.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-services-2-router-interface" {
  region = "${var.region_name}"
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-services-2-subnet.id}"
}

#--- "tf-services-custom" network
resource "openstack_networking_network_v2" "tf-services-custom" {
  name = "tf-services-custom"
  region = "${var.region_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-services-custom-subnet" {
  name = "tf-services-custom-subnet"
  region = "${var.region_name}"
  network_id = "${openstack_networking_network_v2.tf-services-custom.id}"
  cidr = "192.168.32.0/24"
  gateway_ip = "192.168.32.254"
  ip_version = 4

  enable_dhcp = "true"
  allocation_pools {
    start = "192.168.32.2"
    end = "192.168.32.20"
  }
}

resource "openstack_networking_router_interface_v2" "tf-services-custom-router-interface" {
  region = "${var.region_name}"
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-services-custom-subnet.id}"
}

#--- Save generated network id in credhub (used for cloud-config generation)
#   /tf/ namespace is used, to separate credhub-seeder and terraform injected values
resource "credhub_generic" "openstack_networks_net-services-custom" {
  type       = "value"
  name       = "/tf/networks_net-services-custom"
  data_value = "${openstack_networking_network_v2.tf-services-custom.id}"
}