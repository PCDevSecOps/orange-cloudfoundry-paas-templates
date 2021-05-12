#--- Get r1 vpn ip
data "credhub_value" "region_1_vpn_endpoint" {
  name = "/secrets/multi_region_region_1_vpn_endpoint"
}

#--- Set static route to r2 subnet
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-r2-net-bosh-2" {
  router_id        = "${var.router_id}"
  destination_cidr = "192.168.117.0/24"
  next_hop         = "192.168.99.45"
}

#--- Set static route to r2 coab dedicated subnets
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-r2-coab-dedicated-priv" {
  router_id        = "${var.router_id}"
  destination_cidr = "192.168.65.0/24"
  next_hop         = "192.168.99.45"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-r2-coab-dedicated-priv-2" {
  router_id        = "${var.router_id}"
  destination_cidr = "192.168.71.0/24"
  next_hop         = "192.168.99.45"
}