resource "cloudfoundry_organization" "tf-system_domain" {
  name = "system_domain"
  is_system_domain = true
}

resource "cloudfoundry_organization" "org-orange" {
  name = "orange"
}


resource "cloudfoundry_organization" "org-service-sandbox" {
  name = "service-sandbox"
}