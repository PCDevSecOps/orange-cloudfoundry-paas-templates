#--- Set k8s subnet
resource "openstack_networking_network_v2" "tf-net-cfcr-micro" {
  name           = "tf-net-cfcr-micro"
  region         = "${var.region_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf-net-cfcr-micro-subnet" {
  name        = "tf-net-kubo-subnet"
  region      = "${var.region_name}"
  network_id  = "${openstack_networking_network_v2.tf-net-cfcr-micro.id}"
  cidr        = "192.168.243.0/24"
  gateway_ip  = "192.168.243.1"
  ip_version  = 4
  enable_dhcp = "true"

  allocation_pool {
    start = "192.168.243.2"
    end   = "192.168.243.150"
  }
}

resource "openstack_networking_router_interface_v2" "tf-net-cfcr-micro-router-interface" {
  region    = "${var.region_name}"
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.tf-net-cfcr-micro-subnet.id}"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "openstack_networks_net_cfcr_micro" {
  type       = "value"
  name       = "/tf/networks_net-cfcr-micro"
  data_value = "${openstack_networking_network_v2.tf-net-cfcr-micro.id}"
}