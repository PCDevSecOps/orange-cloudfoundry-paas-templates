provider "openstack" {
  auth_url     = "${data.credhub_value.openstack_auth_url.value}"
  user_name    = "${data.credhub_value.openstack_username.value}"
  password     = "${data.credhub_value.openstack_password.value}"
  domain_name  = "${data.credhub_value.openstack_domain.value}"
  tenant_name  = "${data.credhub_value.openstack_project.value}"  
  region       = "${data.credhub_value.openstack_region.value}"
  insecure     = "true"
}
