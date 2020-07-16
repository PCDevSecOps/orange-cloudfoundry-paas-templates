provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

# cloudflare internet cdn routes for projects is in secrets repo
# cloudflare free plans don't yet support wildcard domains that could allow public domains to be shared in templates
