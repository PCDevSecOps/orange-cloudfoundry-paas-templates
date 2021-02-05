provider "openstack" {
  insecure    = "true"
  domain_name = "${var.domain_name}"
  tenant_name = "${var.project_name}"
  region      = "${var.region_name}"
  auth_url    = "${var.auth_url}"
  user_name   = "${var.username}"
  password    = "${var.password}"
}
