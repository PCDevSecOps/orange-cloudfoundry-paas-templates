#--- Cloudflare terraform resources
data "credhub_value" "cloudflare_email" {
  name = "/secrets/cloudflare_email"
}

data "credhub_value" "cloudflare_token" {
  name = "/secrets/cloudflare_token"
}

provider "cloudflare" {
  email = "${data.credhub_value.cloudflare_email.value}"
  token = "${data.credhub_value.cloudflare_token.value}"
  api_client_logging = true
}
