# credhub coordinates injected from shared/secrets.yml / spruce / terraform vars.

variable "credhub_client_id" {
  type        = "string"
  description = "credhub client id"
}

variable "credhub_client_secret" {
  type        = "string"
  description = "credhub client secret"
}

variable "ca_cert" {
  type        = "string"
  description = "private root ca"
}


