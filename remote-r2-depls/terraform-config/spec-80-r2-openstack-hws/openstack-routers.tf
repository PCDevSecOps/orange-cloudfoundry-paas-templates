#z2 router

data "flexibleengine_networking_network_v2" "admin_external_net" {
  name = "admin_external_net"
}

resource "flexibleengine_networking_router_v2" "tf-router-r2" {
  name             = "tf-router-r2"
  external_gateway = "${data.flexibleengine_networking_network_v2.admin_external_net.id}"
}
