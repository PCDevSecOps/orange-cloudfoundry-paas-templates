
# access coordinates/credentials
variable "auth_url" {
  description = "Authentication endpoint URL for OpenStack provider (only scheme+host+port, but without path!)"
}

variable "user_name" {
  description = "OpenStack pipeline technical user name"
}

variable "password" {
  description = "OpenStack user password"
}

variable "tenant_name" {
  description = "OpenStack project/tenant name"
}

variable "region_name" {
  description = "OpenStack region name"
}

variable "insecure" {
  description = "Skip SSL verification"
  default = "false"
}

variable "router_id" {
  description = "public router openstack if"
  default = "false"
}

variable "system_domain" {
  description = "cloudfoundry system domain"
  default = "false"
}

variable "apps_domain" {
  description = "cloudfoundry apps domain"
  default = "false"
}

variable "apps_internet_domain" {
  description = "cloudfoundry apps internet domain"
  default = "false"
}

variable "ops_domain" {
  description = "cloudfoundry ops domain"
  default = "false"
}

