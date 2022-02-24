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
    destination = "${var.osb_data_plane_dedicated_public_cidr}"
    ports = "1-65000"
    log = false
    description = "any TCP to osb_data_plane_dedicated_public"
  }
}

resource "cloudfoundry_sec_group" "sec_group_coab-services_extension_r1" {
  name = "sec-group-coab-services-extension_r1"
  on_staging = false
  on_running = true
  rules {
    protocol = "tcp"
    destination = "${var.osb_data_plane_dedicated_public_cidr_extension_r1}"
    ports = "1-65000"
    log = false
    description = "any TCP to osb_data_plane_dedicated_public extended, r1"
  }
}

resource "cloudfoundry_sec_group" "sec_group_coab-services_extension_r2" {
  name = "sec-group-coab-services-extension_r2"
  on_staging = false
  on_running = true
  rules {
    protocol = "tcp"
    destination = "${var.osb_data_plane_dedicated_public_cidr_extension_r2}"
    ports = "1-65000"
    log = false
    description = "any TCP to osb_data_plane_dedicated_public extended, r2"
  }
}