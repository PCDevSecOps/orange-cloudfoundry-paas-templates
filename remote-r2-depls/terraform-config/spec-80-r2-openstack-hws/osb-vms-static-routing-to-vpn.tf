#--- Static routing to master-depls subnet (for bosh-coab)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-exchange" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.99.0/24"
  next_hop         = "192.168.117.41"
}

#--- Static routing to micro-depls subnet (for dns-recursor)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-micro" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.116.0/24"
  next_hop         = "192.168.117.41"
}

#--- Static routing to coab-depls subnets (for private dedicated vms in r1)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.61.0/24"
  next_hop         = "192.168.117.41"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-2" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.70.0/24"
  next_hop         = "192.168.117.41"
}

#--- Static routing to coab-depls subnets (for private dedicated vms in r3)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-r3" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.68.0/24"
  next_hop         = "192.168.117.41"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-2-r3" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.72.0/24"
  next_hop         = "192.168.117.41"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-3" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.73.0/24"
  next_hop         = "192.168.117.41"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-4" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.76.0/24"
  next_hop         = "192.168.117.41"
}

resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-coab-dedicated-priv-5" {
  router_id = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.77.0/24"
  next_hop         = "192.168.117.41"
}

#--- Static routing to ops-depls subnet (for private shared vms in r1)
resource "flexibleengine_networking_router_route_v2" "tf-static-route-to-ops-shared-priv" {
  router_id        = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
  destination_cidr = "192.168.60.0/24"
  next_hop         = "192.168.117.41"
}
