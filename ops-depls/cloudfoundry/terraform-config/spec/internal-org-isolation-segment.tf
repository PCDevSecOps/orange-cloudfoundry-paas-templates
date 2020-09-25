#--- internal cf organization

resource "cloudfoundry_organization" "org-internal" {
  name = "internal"
}

resource "cloudfoundry_domain" "tf-internal_domain" {
  name = "internal-controlplane-cf.paas"
  org_owner_id = "${cloudfoundry_organization.org-internal.id}"
  shared = false
}

# add running security group
resource "cloudfoundry_sec_group" "sec_group_internal_is" {
  name = "internal_is"
  on_staging = false
  on_running = true
  rules {
    protocol = "tcp"
    destination = "192.168.35.50"
    ports = "443"
    log = true
    description = "tcp access to internal is relay"
  }
}
