#static routing for exchange network (master-depls/bosh-coab)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-exchange" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.99.0/24"
  next_hop         = "192.168.117.41"
}
#static routing for net bosh  network (micro-depls/dns-recursor)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-micro" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.116.0/24"
  next_hop         = "192.168.117.41"
}

#static routing for coab dedicated network (coab-depls/ private dedicated vms in r1)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.61.0/24"
  next_hop         = "192.168.117.41"
}