resource "openstack_networking_port_v2" "tf-haproxy-k8s-serv-port" {
  name           = "tf-haproxy-k8s-serv-port"
  region = "${data.credhub_value.openstack_region.value}"
  network_id     = "${openstack_networking_network_v2.tf-net-kubo.id}"
  admin_state_up = "true"

  fixed_ip {
  	subnet_id = "${openstack_networking_subnet_v2.tf-net-kubo-subnet.id}"
  	ip_address = "192.168.245.150"
  }
}

