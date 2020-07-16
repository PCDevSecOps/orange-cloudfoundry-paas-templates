
data "credhub_certificate" "tls-kubernetes" {
  name = "/bosh-coab/10-cfcr/tls-kubernetes"
}

data "credhub_certificate" "kubo_ca" {
  name = "/bosh-coab/10-cfcr/kubo_ca"
}

data "credhub_value" "kubo-admin-password" {
  name = "/bosh-coab/10-cfcr/kubo-admin-password"
}

provider "kubernetes" {
  host     = "https://cfcr-api-ops.internal.paas"
  username = "kubo-cluster-admin"                                     # credential_leak_validated
  password = "${data.credhub_value.kubo-admin-password.value}"

  client_certificate     = "${data.credhub_certificate.tls-kubernetes.certificate}"
  client_key             = "${data.credhub_certificate.tls-kubernetes.private_key}"
  cluster_ca_certificate = "${data.credhub_certificate.kubo_ca.certificate}"
}
