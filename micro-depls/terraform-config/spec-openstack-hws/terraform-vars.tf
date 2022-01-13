#--- Openstack keystone authentication
variable "domain_name" {}

variable "project_name" {}
variable "region_name" {}
variable "auth_url" {}
variable "username" {}
variable "password" {}

#--- VPC PAAS
variable "vpc_paas_cidr" {}

variable "router_id" {}
variable "vpc_paas_range" {}

#--- Domains
variable "system_domain" {
  description = "cloudfoundry system domain"
  default     = "false"
}

variable "apps_domain" {
  description = "cloudfoundry apps domain"
  default     = "false"
}

variable "apps_internet_domain" {
  description = "cloudfoundry apps internet domain"
  default     = "false"
}

variable "ops_domain" {
  description = "cloudfoundry ops domain"
  default     = "false"
}

#--- Cloudflare
variable "cloudflare_email" {
  type        = "string"
  description = "cloudflare account login as an email address"
}

variable "cloudflare_token" {
  type        = "string"
  description = "cloudflare account token"
}

#--- OpenVPN
variable "openvpn_clients_cidr" {
  type        = "string"
  description = "OpenVPN CIDR clients enable to connect to OpenVPN server"
}

#--- TCP Routing
variable "default_router_group_reservable_port_min" {
  type        = "string"
  description = "Min TCP port reservable for TCP Routing"
}

variable "default_router_group_reservable_port_max" {
  type        = "string"
  description = "Max TCP port reservable for TCP Routing"
}

#========================================================================
# Vars needed for bootstrap
#========================================================================
#--- ssh instances key
variable "key_pair_name" {}

#--- Instances
variable "public_image_id" {}

variable "availability_zone" {}
