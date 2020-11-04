resource "openstack_networking_port_v2" "tf-haproxy-k8s-micro-port" {
  name           = "tf-haproxy-k8s-micro-port"
  region = "${var.region_name}"  
  network_id     = "${openstack_networking_network_v2.tf-net-cfcr-micro.id}"
  admin_state_up = "true"

  fixed_ip {
  	subnet_id = "${openstack_networking_subnet_v2.tf-net-cfcr-micro-subnet.id}"
  	ip_address = "192.168.243.150"
  }
}

