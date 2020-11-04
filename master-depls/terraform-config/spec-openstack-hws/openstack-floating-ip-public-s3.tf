#allocate a floating ip, pool is external_network_name
resource "flexibleengine_networking_floatingip_v2" "public-s3-relay-floating-ip" {
  pool = "admin_external_net"
}

#outputs the generated floating ip (must be saved in credhub)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values

resource "credhub_generic" "public-s3-relay-floating-ip" {
  type       = "value"
  name       = "/tf/public-s3-relay-floating-ip"
  data_value = "${flexibleengine_networking_floatingip_v2.public-s3-relay-floating-ip.address}"
}