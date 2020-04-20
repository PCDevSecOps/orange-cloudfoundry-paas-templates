# see cloudfoundry.org doc
# https://docs.cloudfoundry.org/concepts/asg.html#public-networks-example



data "cloudfoundry_sec_group" "sec-group-wide-open" {
  name = "wide-open"
}

#any TCP to NET_CF_SERVICES, NET_CF_SERVICES_2, tf-net-expe
data "cloudfoundry_sec_group" "sec_group_services" {
  name = "services"
}

#any ICMP to NET_CF_SERVICES
data "cloudfoundry_sec_group" "sec_group_services-ping" {
  name = "services-ping"
}

#https to cloudfoundry haproxy (used by coab smoke tests)
data "cloudfoundry_sec_group" "sec_group_cf" {
  name = "cf"
}

#http(s) to app domain. elpaaso-rp-intranet (used by coab smoke tests)
data "cloudfoundry_sec_group" "sec_group_cf_domains" {
  name = "cf_domains"
}

