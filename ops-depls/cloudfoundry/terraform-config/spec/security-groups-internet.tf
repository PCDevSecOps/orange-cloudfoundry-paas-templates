resource "cloudfoundry_sec_group" "sec_group_internet_proxy" {
  name = "system-internet"
  on_staging = true
  on_running = false
  rules {
    protocol = "tcp"
    destination = "192.168.116.80"
    ports = "3128"
    log = true
    description = "internet proxy squid 3128, @internet"
  }
}
