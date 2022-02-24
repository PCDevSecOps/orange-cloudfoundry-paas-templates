#--- Openstack authentication
data "credhub_value" "openstack_tenant_name" {
  name = "/secrets/openstack_3_tenant_name"
}

data "credhub_value" "openstack_region" {
  name = "/secrets/openstack_3_region"
}

data "credhub_value" "openstack_auth_url" {
  name = "/secrets/openstack_3_auth_url"
}

data "credhub_value" "openstack_username" {
  name = "/secrets/openstack_3_username"
}

data "credhub_value" "openstack_password" {
  name = "/secrets/openstack_3_password"
}

#--- Providers
provider "openstack" {
  insecure     = "true"
  domain_name  = "${data.credhub_value.openstack_tenant_name.value}"
  tenant_name  = "${data.credhub_value.openstack_region.value}"
  region       = "${data.credhub_value.openstack_region.value}"
  auth_url     = "${data.credhub_value.openstack_auth_url.value}"
  user_name    = "${data.credhub_value.openstack_username.value}"
  password     = "${data.credhub_value.openstack_password.value}"
}

provider "flexibleengine" {
  insecure     = "true"
  domain_name = "${data.credhub_value.openstack_tenant_name.value}"
  tenant_name = "${data.credhub_value.openstack_region.value}"
  region      = "${data.credhub_value.openstack_region.value}"
  auth_url    = "${data.credhub_value.openstack_auth_url.value}"
  user_name   = "${data.credhub_value.openstack_username.value}"
  password    = "${data.credhub_value.openstack_password.value}"
}