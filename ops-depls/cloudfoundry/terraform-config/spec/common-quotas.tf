resource "cloudfoundry_quota" "tf_org_system_domain_quota" {
  name = "tf_org_system_domain_quota"
  org_id = "${cloudfoundry_organization.tf-system_domain.id}"
  total_memory = "50G"
  instance_memory = "20G"
  routes = 200
  service_instances = 100
  app_instances = -1
  allow_paid_service_plans = true
  reserved_route_ports = 0
}
