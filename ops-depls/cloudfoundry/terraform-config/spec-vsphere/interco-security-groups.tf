# interco specific security groups
# config multi-nic (openstack), security groups target private ips


data "credhub_value" "to_intranet_ip" {
  name = "/secrets/intranet_interco_ips_to_intranet"
}

data "credhub_value" "ops_ip" {
  name = "/secrets/intranet_interco_ips_ops"
}

resource "cloudfoundry_sec_group" "sec_group_mail" {
  name = "mail-fed"
  on_staging = false
  on_running = false
  rules {
    protocol = "tcp"
    destination = "${data.credhub_value.to_intranet_ip.value}"
    ports = "25"
    log = true
    description = "smtp 25 to elpaaso-mail"
  }
}

resource "cloudfoundry_sec_group" "sec_group_cf" {
  name = "cf"
  on_staging = false
  on_running = true
  rules {
    protocol = "tcp"
    destination = "192.168.35.59"
    ports = "443"
    log = true
    description = "https to cloudfoundry API haproxy"
  }
}

resource "cloudfoundry_sec_group" "sec_group_cf_ssh" {
  name = "cf-ssh-internal"
  on_staging = false
  on_running = false
  rules {
    protocol = "tcp"
    destination = "192.168.35.59"
    ports = "80"
    log = true
    description = "cf ssh to cloudfoundry API haproxy"
  }
}


resource "cloudfoundry_sec_group" "sec_group_ops" {
  name = "ops"
  on_staging = false
  on_running = false
  rules {
    protocol = "tcp"
    destination = "192.168.99.30"
    ports = "443"
    log = true
    description = "https to ops domain haproxy"
  }
}

resource "cloudfoundry_sec_group" "sec_group_cf_domains" {
  name = "cf_domains"
  on_staging = false
  on_running = true
  rules {
    protocol = "tcp"
    destination = "192.168.35.60"
    ports = "80"
    log = true
    description = "http to app domain. elpaaso-rp-intranet"
  }
  rules {
    protocol = "tcp"
    destination = "192.168.35.60"
    ports = "443"
    log = true
    description = "https to app domain. elpaaso-rp-intranet"
  }
}
