resource "openstack_networking_port_v2" "tf-haproxy-k8s-master-port" {
  name           = "tf-haproxy-k8s-master-port"
  region = "${var.region_name}"  
  network_id     = "${openstack_networking_network_v2.tf-net-cfcr-master.id}"
  admin_state_up = "true"

  fixed_ip {
  	subnet_id = "${openstack_networking_subnet_v2.tf-net-cfcr-master-subnet.id}"
  	ip_address = "192.168.244.150"
  }
}

