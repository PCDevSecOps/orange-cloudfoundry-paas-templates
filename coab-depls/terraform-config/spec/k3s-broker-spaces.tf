resource "cloudfoundry_space" "coa-k3s-smoke-tests-space" {
  name = "coa-k3s-smoke-tests"
  org_id = "${data.cloudfoundry_organization.org-service-sandbox.id}"
  sec_groups = [
    "${data.cloudfoundry_sec_group.sec_group_cf.id}",
    #call CF API
    "${data.cloudfoundry_sec_group.sec_group_cf_domains.id}"
    #call smoke test CF app
    # "${cloudfoundry_sec_group.sec_group_coab-services.id}", Not need as it is registered as a default running asg. See https://github.com/orange-cloudfoundry/terraform-provider-cloudfoundry/blob/4703d9062a67ddd1ab7237557f1b8f8c6a17d786/resources/security_groups.go#L123-L135
  ]
  allow_ssh = true

  # Disabled waiting for fix to https://github.com/orange-cloudfoundry/terraform-provider-cloudfoundry/issues/34
  #
  # Restrict number of services instances to prevent smoke tests from leaking too many bosh deployments
  #quota_id = "${cloudfoundry_quota.tf_coab_smoketests_quota.id}"
}

resource "cloudfoundry_space" "coa-k3s-broker-space" {
  name = "coa-k3s-broker"
  org_id = "${data.cloudfoundry_organization.tf-system_domain.id}"
  sec_groups = [
    "${data.cloudfoundry_sec_group.sec-group-wide-open.id}"
    #enable gitlab https access workaround because vrrp doesn't work
  ]

  allow_ssh = true
}


# Disabled waiting for fix to https://github.com/orange-cloudfoundry/terraform-provider-cloudfoundry/issues/34
#
#resource "cloudfoundry_quota" "tf_coab_smoketests_quota" {
#  name = "tf_coab_smoketests_quota"
#  total_memory = "2G"
#  instance_memory = "2G"
#  routes = 5
#  service_instances = 15
#  #Restrict to 15
#  app_instances = 5
#  allow_paid_service_plans = true
#  reserved_route_ports = 0
#}

