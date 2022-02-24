data "credhub_value" "system_domain" {
  name = "/secrets/cloudfoundry_system_domain"
}
data "credhub_value" "cloudfoundry_apps_domain" {
  name = "/secrets/cloudfoundry_apps_domain"
}
