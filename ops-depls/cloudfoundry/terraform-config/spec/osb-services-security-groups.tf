resource "cloudfoundry_sec_group" "sec_group_osb" {
  name = "osb"
  on_staging = false
  on_running = true
  rules {
    protocol = "tcp"
    destination = "${var.osb_shared_destination}"
    ports = "1-65000"
    log = false
    description = "any TCP to tf-net-osb-data-plane-shared-pub"
  }
}

