# see cloudfoundry.org doc
# https://docs.cloudfoundry.org/concepts/asg.html#public-networks-example
resource "cloudfoundry_sec_group" "public_networks" {
  name = "public_networks"
  on_staging = true
  on_running = false
  rules {
    protocol = "tcp"
    destination = "0.0.0.0-9.255.255.255"
    ports = "1-65000"
    log = false
    description = "any internet address address"
  }
  rules {
    protocol = "tcp"
    destination = "11.0.0.0-169.253.255.255"
    ports = "1-65000"
    log = false
    description = "any internet address address"
  }
  rules {
    protocol = "tcp"
    destination = "169.255.0.0-172.15.255.255"
    ports = "1-65000"
    log = false
    description = "any internet address address"
  }
  rules {
    protocol = "tcp"
    destination = "172.32.0.0-192.167.255.255"
    ports = "1-65000"
    log = false
    description = "any internet address address"
  }
  rules {
    protocol = "tcp"
    destination = "192.169.0.0-255.255.255.255"
    ports = "1-65000"
    log = false
    description = "any internet address address"
  }
}

resource "cloudfoundry_sec_group" "sec-group-wide-open" {
  name = "wide-open"
  on_staging = false
  on_running = false
  rules {
    protocol = "tcp"
    destination = "0.0.0.0/0"
    ports = "1-65000"
    log = false
    description = "any TCP to any address"
  }
  rules {
    protocol = "udp"
    destination = "0.0.0.0/0"
    ports = "1-65000"
    log = false
    description = "any UDP to any address"
  }
}

resource "cloudfoundry_sec_group" "sec_group_dns" {
  name = "tf-dns"
  on_staging = true
  on_running = true
  rules {
    protocol = "tcp"
    destination = "192.168.116.156"
    ports = "53"
    log = false
    description = "TCP 53"
  }
  rules {
    protocol = "udp"
    destination = "192.168.116.166"
    ports = "53"
    log = false
    description = "UDP 53"
  }
  rules {
    protocol = "tcp"
    destination = "192.168.116.165"
    ports = "53"
    log = false
    description = "TCP 53"
  }
  rules {
    protocol = "udp"
    destination = "192.168.116.165"
    ports = "53"
    log = false
    description = "UDP 53"
  }
}

resource "cloudfoundry_sec_group" "sec_group_services" {
  name = "services"
  on_staging = false
  on_running = true
  rules {
    protocol = "tcp"
    destination = "192.168.30.0/24"
    ports = "1-65000"
    log = false
    description = "any TCP to NET_CF_SERVICES"
  }
  rules {
    protocol = "tcp"
    destination = "192.168.31.0/24"
    ports = "1-65000"
    log = false
    description = "any TCP to NET_CF_SERVICES_2"
  }
}

resource "cloudfoundry_sec_group" "sec_group_services-ping" {
  name = "services-ping"
  on_staging = false
  on_running = true
  rules {
    protocol = "icmp"
    destination = "192.168.30.0/24"
    code = "0"
    type = "0"
    log = false
    description = "any ICMP to NET_CF_SERVICES"
  }
}

resource "cloudfoundry_sec_group" "sec_group_fpv_internet" {
  name = "fpv-internet"
  on_staging = true
  on_running = false
  rules {
    protocol = "tcp"
    destination = "192.168.116.130" 
    ports = "3128"
    log = true
    description = "squid 3128, @internet"
  }
}

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


resource "cloudfoundry_sec_group" "sec_group_ldap" {
  name = "ldap"
  on_staging = false
  on_running = false
  rules {
    protocol = "tcp"
    destination = "192.168.99.60"
    ports = "389"
    log = true
    description = "Allow internal ldap access"
  }
}

resource "cloudfoundry_sec_group" "sec_group_admin_ui"  {
  name = "admin-ui"
  on_staging = false
  on_running = false
  rules {
    protocol = "tcp"
    destination = "192.168.35.0/24"
    ports = "1-65535"
    log = true
    description = "Allow admin-ui nats access"
  }
  rules {
    protocol = "tcp"
    destination = "192.168.99.70"
    ports = "5524"
    log = true
    description = "Allow admin-ui postgres access"
  }
}
