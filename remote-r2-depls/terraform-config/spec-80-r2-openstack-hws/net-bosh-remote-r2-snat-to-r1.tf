resource "flexibleengine_nat_gateway_v2" "tf-nat-to-r1" {
  name   = "tf-nat-to-r1"
  description = "nat gateway service to r1 - required for bootstrap compilation vms"
  spec = "2"
  router_id = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  internal_network_id = "${openstack_networking_network_v2.tf_net_bosh_remote_2.id}"
}

#define floating ip for nat
#allocate a floating ip, pool is external_network_name
resource "flexibleengine_networking_floatingip_v2" "tf-nat-r2-floating-ip" {
  pool = "admin_external_net"
}

resource "flexibleengine_nat_snat_rule_v2" "tf-nat-r2-gateway-snat" {
  nat_gateway_id = "${flexibleengine_nat_gateway_v2.tf-nat-to-r1.id}"
  network_id = "${openstack_networking_network_v2.tf_net_bosh_remote_2.id}"
  floating_ip_id = "${flexibleengine_networking_floatingip_v2.tf-nat-r2-floating-ip.id}"
}

