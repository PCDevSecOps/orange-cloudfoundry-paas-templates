data "cloudfoundry_organization" "org-orange-internet" {
  name = "orange-internet"
}

data "cloudfoundry_organization" "org-orange-private-sandboxes" {
  name = "orange-private-sandboxes"
}

data "cloudfoundry_organization" "tf-system_domain" {
  name = "system_domain"
}

data "cloudfoundry_organization" "org-orange" {
  name = "orange"
}

data "cloudfoundry_organization" "org-service-sandbox" {
  name = "service-sandbox"
}