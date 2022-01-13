variable "cloudflare_email" {
  type = "string"
  description = "cloudflare account login as an email address"
}
variable "cloudflare_token" {
  type = "string"
  description = "cloudflare account token "
}
variable "cloudflare_internet_domain" {
  type = "string"
  description = "target CNAME of the public internet routes (e.g. vip-cw-vdr-pprod-apps.elpaaso.net)"
}
variable "cloudflare_root_domain" {
  type = "string"
  description = "root domain of the cloudflare routes (e.g. elpaaso.net)"
}
