
resource "cloudfoundry_org" "internal-org" {
    name = "internal"
}

resource "cloudfoundry_isolation_segment" "internal_isolation_segment" {
  name = "internal_isolation_segment"
}

resource "cloudfoundry_isolation_segment_entitlement" "internal-is-entitlement" {
  segment = cloudfoundry_isolation_segment.internal_isolation_segment.id
  default = true
  orgs = [
    cloudfoundry_org.internal-org.id
  ]
}

resource "cloudfoundry_domain" "tf-internal_domain" {
  name = "internal-controlplane-cf.paas"
  org = cloudfoundry_org.internal-org.id
}


# add running security group
resource "cloudfoundry_asg" "sec_group_internal_is" {
    name = "internal_is"
    rule {
        protocol = "tcp"
        destination = "192.168.35.50"
        ports = "443"
        log = true
        description = "tcp access to internal is relay"
  }

}