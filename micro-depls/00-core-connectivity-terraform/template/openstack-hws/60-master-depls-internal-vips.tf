# lookup existing tf-net-bosh-2 network and subnet

data "openstack_networking_network_v2" "tf-net-exchange" {
  name = "tf-net-exchange"
}

data "openstack_networking_subnet_v2" "tf-net-exchange-subnet" {
  name = "tf-net-exchange-subnet"

}



data "openstack_networking_network_v2" "tf-net-osb-data-plane-shared-priv" {
  name = "tf-net-osb-data-plane-shared-priv"
}

data "openstack_networking_subnet_v2" "tf-net-osb-data-plane-shared-priv-subnet" {
  name = "tf-net-osb-data-plane-shared-priv-subnet"

}





resource "openstack_networking_port_v2" "k3s-sandbox-vip-port" {
  name = "k3s-sandbox-vip-port"
  region = var.openstack_region_name  
  network_id = data.openstack_networking_network_v2.tf-net-exchange.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.tf-net-exchange-subnet.id
    ip_address = "192.168.99.15"
  }
}

resource "openstack_networking_port_v2" "supervision-vip-port" {
  name = "00-supervision-vip-port"
  region = var.openstack_region_name  
  network_id = data.openstack_networking_network_v2.tf-net-exchange.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.tf-net-exchange-subnet.id
    ip_address = "192.168.99.16"
  }
}


resource "openstack_networking_port_v2" "supervision-syslog-vip-port" {
  name = "00-supervision-syslog-vip-port"
  region = var.openstack_region_name  
  network_id = data.openstack_networking_network_v2.tf-net-exchange.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.tf-net-exchange-subnet.id
    ip_address = "192.168.99.17"
  }
}

resource "openstack_networking_port_v2" "marketplace-vip-port" {
  name = "marketplace-vip-port"
  region = var.openstack_region_name  
  network_id = data.openstack_networking_network_v2.tf-net-exchange.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.tf-net-exchange-subnet.id
    ip_address = "192.168.99.18"
  }
}

resource "openstack_networking_port_v2" "shared-services-vip-port" {
  name = "shared-services-vip-port"
  region = var.openstack_region_name  
  network_id = data.openstack_networking_network_v2.tf-net-osb-data-plane-shared-priv.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.tf-net-osb-data-plane-shared-priv-subnet.id
    ip_address = "192.168.60.15"
  }
}


resource "openstack_networking_port_v2" "shared-services-k8s-api-vip-port" {
  name = "shared-services-k8s-api-vip-port"
  region = var.openstack_region_name  
  network_id = data.openstack_networking_network_v2.tf-net-osb-data-plane-shared-priv.id
  admin_state_up = "true"
  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.tf-net-osb-data-plane-shared-priv-subnet.id
    ip_address = "192.168.60.16"
  }
}
