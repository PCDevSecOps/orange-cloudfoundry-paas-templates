resource "cloudfoundry_sec_group" "sec_group_ldap" {
  name = "ldap"
  on_staging = false
  on_running = false
  rules {
    protocol = "tcp"
    destination = "192.168.116.19"
    ports = "389"
    log = true
    description = "Allow internal ldap access"
  }
}
