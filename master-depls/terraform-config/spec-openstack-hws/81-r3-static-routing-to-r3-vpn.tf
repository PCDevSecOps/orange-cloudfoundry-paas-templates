#--- Set static route to r3 subnet
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-r3-net-bosh-2" {
  router_id        = "${var.router_id}"
  destination_cidr = "192.168.118.0/24"
  next_hop         = "192.168.99.45"
}

#--- Set static route to r3 coab dedicated subnets
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-r3-coab-dedicated-priv" {
  router_id        = "${var.router_id}"
  destination_cidr = "192.168.68.0/24"
  next_hop         = "192.168.99.45"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-r3-coab-dedicated-priv-2" {
  router_id        = "${var.router_id}"
  destination_cidr = "192.168.72.0/24"
  next_hop         = "192.168.99.45"
}