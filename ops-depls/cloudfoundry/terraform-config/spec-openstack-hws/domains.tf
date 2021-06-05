resource "cloudfoundry_domain" "tf-internet-paas-apps-domain" {
  name = "${var.cloudfoundry["apps_internet_domain_2"]}"
  org_owner_id = "${cloudfoundry_organization.tf-system_domain.id}"
}
