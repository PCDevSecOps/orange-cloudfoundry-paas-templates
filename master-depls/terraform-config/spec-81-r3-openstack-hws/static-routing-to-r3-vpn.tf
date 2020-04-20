#static routing for r3  net-bosh network
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-r3-net-bosh-2" {
  router_id = "${var.router_id}"
  destination_cidr = "192.168.118.0/24"
  next_hop         = "${data.credhub_value.region_1_vpn_endpoint.value}"
}

#static routing for coab dedicated network (coab-depls/ private dedicated vms in r3)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-r3-coab-dedicated-priv" {
  router_id = "${var.router_id}"
  destination_cidr = "192.168.68.0/24"
  next_hop         = "${data.credhub_value.region_1_vpn_endpoint.value}"
}