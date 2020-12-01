resource "cloudfoundry_quota" "tf_org_quota" {
  name = "tf_org_quota"
  org_id = "${cloudfoundry_organization.org-orange-internet.id}"
  total_memory = "10G"
  instance_memory = "1G"
  routes = 200
  service_instances = 10
  app_instances = -1
  allow_paid_service_plans = true
  reserved_route_ports = 0
}



