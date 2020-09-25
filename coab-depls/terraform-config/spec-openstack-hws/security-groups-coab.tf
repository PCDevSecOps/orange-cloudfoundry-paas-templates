# see cloudfoundry.org doc
# https://docs.cloudfoundry.org/concepts/asg.html#public-networks-example

#Open all spaces to access to coab services,
# Won't open dynamically sec groups, see
# https://github.com/orange-cloudfoundry/sec-group-broker-filter/issues/53
# Don't use the "sec_group_services" from ops-depls/cloudfoundry/terraform-config/spec/security-groups.tf
# so that changes in CIDR properly gets reflected.
resource "cloudfoundry_sec_group" "sec_group_coab-services" {
  name = "sec-group-coab-services"
  on_staging = false
  on_running = true
  rules {
    protocol = "tcp"
    destination = "${openstack_networking_subnet_v2.tf-net-coab-depls-instance-subnet.cidr}"
    ports = "1-65000"
    log = false
    description = "any TCP to coab tf-net-coab-depls-instance"
  }
}
