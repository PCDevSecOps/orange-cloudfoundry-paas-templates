#--- Intranet interco 2 cf organization
data "credhub_value" "intranet_2_cf_org" {
  name = "/secrets/intranet_interco_2/cf_org"
}

resource "cloudfoundry_organization" "org-intranet-2" {
  name = "${data.credhub_value.intranet_2_cf_org.value}"
}

#--- cf isolation-segment for intranet interco 2 exposed apps
resource "cloudfoundry_isolation_segment" "intranet_2_isolation_segment" {
  name = "intranet_2_isolation_segment"
  orgs_id = ["${cloudfoundry_organization.org-intranet-2.id}"]
}

resource "cloudfoundry_isolation_segment_entitlement" "intranet-2-is-entitlement" {
  segment_id = "${cloudfoundry_isolation_segment.intranet_2_isolation_segment.id}"
  org_id = "${cloudfoundry_organization.org-intranet-2.id}"
  default = true
}

#--- Intranet interco 2 cf domain
data "credhub_value" "intranet_2_domain" {
  name = "/secrets/intranet_interco_2/apps_domain"
}

resource "cloudfoundry_domain" "tf-intranet_2_domain" {
  name = "${data.credhub_value.intranet_2_domain.value}"
  org_owner_id = "${cloudfoundry_organization.org-intranet-2.id}"
  shared = false
}

#TODO: define specif cloudfoundry outbound security groups: ie dns, gateway