#define floating ip for r2 bootstrap vm
#allocate a floating ip, pool is external_network_name
resource "flexibleengine_networking_floatingip_v2" "tf-bosh-remote-r2-floating-ip" {
  pool = "admin_external_net"
}

#--- Outputs the generated network id (must be saved in credhub for cloud-config generation)
# /tf/ namespace is used, to separate credhub-seeder injected and terraform injected values
resource "credhub_generic" "bosh-remote-r2-bootstap-floating-ip" {
  type       = "value"
  name       = "/tf/bosh-remote-r2-floating-ip"
  data_value = "${flexibleengine_networking_floatingip_v2.tf-bosh-remote-r2-floating-ip.address}"
}
