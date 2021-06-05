#--- Set peerings
#resource "flexibleengine_vpc_peering_connection_v2" "peering-r1-r2" {
#  name        = "peering-z1-z2"
#  vpc_id      = "${flexibleengine_networking_router_v2.tf-router-r1.id}"
#  peer_vpc_id = "${flexibleengine_networking_router_v2.tf-router-r2.id}"
#}