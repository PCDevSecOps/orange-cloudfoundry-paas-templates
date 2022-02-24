data "credhub_value" "tcp-routing-shared-domain" {
  name = "/secrets/cloudfoundry_tcp_routing_domain"
}

resource "cloudfoundry_domain" "tf-tcp-shared-domain" {
  name = "${data.credhub_value.tcp-routing-shared-domain.value}"
  router_group = "default-tcp"
  shared = true
}

