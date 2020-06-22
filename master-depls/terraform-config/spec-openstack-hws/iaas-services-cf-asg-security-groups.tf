# see cloudfoundry.org doc
# https://docs.cloudfoundry.org/concepts/asg.html#public-networks-example
resource "cloudfoundry_sec_group" "sec_group_iaas_services" {
  name = "iaas_services"
  on_staging = false
  on_running = true
  rules {
    protocol = "tcp"
    destination = "192.168.30.0/24"
    ports = "1-65000"
    log = false
    description = "any TCP to NET_CF_SERVICES"
  }
  rules {
    protocol = "tcp"
    destination = "172.24.1.0/24"
    ports = "1-65000"
    log = false
    description = "any TCP to tf-net-iaas-services"
  }
}

resource "cloudfoundry_sec_group" "sec_group_services-ping" {
  name = "iaas_services-ping"
  on_staging = false
  on_running = true
  rules {
    protocol = "icmp"
    destination = "172.24.1.0/24"
    code = "0"
    type = "0"
    log = false
    description = "any ICMP to tf-net-iaas-services"
  }
}
