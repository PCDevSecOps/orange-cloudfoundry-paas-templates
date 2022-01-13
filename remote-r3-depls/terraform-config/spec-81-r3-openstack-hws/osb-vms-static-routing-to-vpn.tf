#--- Static routing to master-depls subnet (for bosh-coab)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-exchange" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  destination_cidr = "192.168.99.0/24"
  next_hop         = "192.168.118.41"
}

#--- Static routing to micro-depls subnet (for dns-recursor)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-micro" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  destination_cidr = "192.168.116.0/24"
  next_hop         = "192.168.118.41"
}

#--- Static routing to coab-depls subnets (for private dedicated vms in r1)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  destination_cidr = "192.168.61.0/24"
  next_hop         = "192.168.118.41"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-2" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  destination_cidr = "192.168.70.0/24"
  next_hop         = "192.168.118.41"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-3" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  destination_cidr = "192.168.73.0/24"
  next_hop         = "192.168.118.41"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-4" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  destination_cidr = "192.168.76.0/24"
  next_hop         = "192.168.118.41"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-5" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  destination_cidr = "192.168.77.0/24"
  next_hop         = "192.168.118.41"
}

#static routing for coab dedicated network (coab-depls/ private dedicated vms in r2)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-r2" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  destination_cidr = "192.168.65.0/24"
  next_hop         = "192.168.118.41"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-2-r2" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  destination_cidr = "192.168.71.0/24"
  next_hop         = "192.168.118.41"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-3-r2" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r3.id}"
  destination_cidr = "192.168.74.0/24"
  next_hop         = "192.168.118.41"
}