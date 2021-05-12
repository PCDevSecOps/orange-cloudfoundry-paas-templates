
# Also registers the cloudfoundry domain and routes

variable "space_guid" {
  type = "string"
  description = "create service instance: space guid"
}
variable "org_guid" {
  type = "string"
  description = "create service instance: org guid"
}

variable "service_instance_guid" {
  type = "string"
  description = "create service instance: service instance guid"
}
variable "route-prefix" {
  type = "string"
  description = "create service instance arbitrary param: route prefix provided by end user"
  # TODO: check if input validation can be performed within terraform or needs to be applied upstream
}
variable "cloudflare_internet_domain" {
  type = "string"
  description = "target CNAME of the public internet routes (e.g. vip-cw-vdr-pprod-apps.elpaaso.net)"
}
variable "cloudflare_root_domain" {
  type = "string"
  description = "root domain of the cloudflare routes (e.g. elpaaso.net)"
}
variable "cloudflare_route_suffix" {
  type = "string"
  description = "root domain of the cloudflare routes (e.g. -cdn-cw-vdr-pprod-apps)"
}

# In the future, these data sources will be usefull to lookup the org name and possibly use it into meta-data
#
# org into which the new private domain should be provisionned
#data "cloudfoundry_organization" "org_on_demand_internet_route" {
#  # name = "${var.org_guid}" #TODO: provider improvement to fetch from variable provided by user
#  name = "${var.org_name}"
#}
#
# space into which a route should be provisionned
#data "cloudfoundry_space" "space_on_demand_internet_route" {
#  # name = "${var.space_guid}" #TODO: provider improvement to fetch from variable provided by user
#  name = "test"
#  org_id = "${data.cloudfoundry_organization.org_on_demand_internet_route.id}"
#}

resource "cloudflare_record" "on-demand-cloudflare-route" {
  name = "${var.route-prefix}${var.cloudflare_route_suffix}"
  domain = "${var.cloudflare_root_domain}"
  type = "CNAME"
  value = "${var.cloudflare_internet_domain}"
  proxied = "true"
}

resource "cloudfoundry_domain" "on-demand-cloudflare-domain" {
  #name = "route2-cdn-cw-vdr-pprod-apps.elpaaso.net"
  name = "${cloudflare_record.on-demand-cloudflare-route.name}.${cloudflare_record.on-demand-cloudflare-route.domain}"
  #org_owner_id = "${cloudfoundry_organization.org-orange-internet.id}"
  org_owner_id = "${var.org_guid}"
}

# reserve the route in the space so that other projects in the same org can't use it.
# Q: is it a good idea ? Projects might try to delete it.
resource "cloudfoundry_route" "route_app" {
  hostname = ""
  space_id = "${var.space_guid}"
  domain_id = "${cloudfoundry_domain.on-demand-cloudflare-domain.id}"
}


output "started" {
  description = "tracked module was invoked"
  value = "successfully received module invocation"
}

# This output would not be initially added if one of the referred resource is missing.
# Note however that due to https://github.com/hashicorp/terraform/issues/13555 outputs won't
# be updated when resources would be recreated by TF following an external removal
output "completed" {
  description = "provides a completion status of the module to be tracked by the broker"
  value = "successfully provisionned ${cloudflare_record.on-demand-cloudflare-route.name} ${cloudfoundry_domain.on-demand-cloudflare-domain.name} and ${cloudfoundry_route.route_app.domain_id}"
}