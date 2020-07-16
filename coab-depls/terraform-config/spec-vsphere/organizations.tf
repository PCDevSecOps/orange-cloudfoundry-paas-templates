
data "cloudfoundry_organization" "tf-system_domain" {
  name = "system_domain"
}

data "cloudfoundry_organization" "org-orange" {
  name = "orange"
}

data "cloudfoundry_organization" "org-service-sandbox" {
  name = "service-sandbox"
}