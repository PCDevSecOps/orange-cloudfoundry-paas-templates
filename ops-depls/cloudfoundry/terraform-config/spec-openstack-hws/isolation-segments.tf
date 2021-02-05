#define cf isolation-segment for internet exposed apps
resource "cloudfoundry_isolation_segment" "internet_isolation_segment" {
  name = "internet_isolation_segment"
}

resource "cloudfoundry_isolation_segment_entitlement" "internet-is-entitlement" {
  segment_id = "${cloudfoundry_isolation_segment.internet_isolation_segment.id}"
  org_id = "${cloudfoundry_organization.org-orange-internet.id}"
  default = true
}
