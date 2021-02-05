#see https://github.com/orange-cloudfoundry/terraform-provider-credhub
provider "credhub" {
  credhub_server      = "https://credhub.internal.paas:8844"
  skip_ssl_validation = false
  client_id           = "${var.credhub_client_id}"
  client_secret       = "${var.credhub_client_secret}"
  ca_cert             = "${var.ca_cert}"
}
