

resource "cloudfoundry_space" "smtp-brokers" {
    name = "smtp-brokers"
    org_id = "${cloudfoundry_organization.tf-system_domain.id}"
    sec_groups = ["${cloudfoundry_sec_group.sec_group_ops.id}"]
    allow_ssh = true
}

#FIXME: if ok, redeclare here all spaces created by cf-apps-deployments (enable-cf-app.yml)


#concourse micro sso space
resource "cloudfoundry_space" "concourse-authent-space" {
    name = "concourse-authent-space"
    org_id = "${cloudfoundry_organization.tf-system_domain.id}"
    sec_groups = ["${cloudfoundry_sec_group.sec_group_ops.id}"]
    allow_ssh = true
}

resource "cloudfoundry_space" "mongodb-smoke-tests-space" {
    name = "mongodb-smoke-tests"
    org_id = "${cloudfoundry_organization.org-service-sandbox.id}"
    sec_groups = ["${cloudfoundry_sec_group.sec_group_services.id}"]
    allow_ssh = true
}