# get vpn r1 ip
data "credhub_value" "region_1_vpn_endpoint" {
  name = "/secrets/multi_region_region_1_vpn_endpoint"
}



#static routing for r2  net-bosh network
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-r2-net-bosh-2" {
  router_id = "${var.router_id}"
  destination_cidr = "192.168.117.0/24"
  next_hop         = "${data.credhub_value.region_1_vpn_endpoint.value}"
}

#static routing for coab dedicated network (coab-depls/ private dedicated vms in r2)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-r2-coab-dedicated-priv" {
  router_id = "${var.router_id}"
  destination_cidr = "192.168.65.0/24"
  next_hop         = "${data.credhub_value.region_1_vpn_endpoint.value}"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-r2-coab-dedicated-priv-2" {
  router_id = "${var.router_id}"
  destination_cidr = "192.168.71.0/24"
  next_hop         = "${data.credhub_value.region_1_vpn_endpoint.value}"
}