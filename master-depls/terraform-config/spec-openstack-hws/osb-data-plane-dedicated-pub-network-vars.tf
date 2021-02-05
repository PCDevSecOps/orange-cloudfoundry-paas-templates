# variables of the osb data plane dedicated public network
variable "osb_dedicated_cidr" {
  description = "CIDR/Range of osb data plane dedicated public network"
}

variable "osb_dedicated_gateway_ip" {
  description = "gateway_ip of osb data plane dedicated public network"
}

variable "osb_dedicated_dhcp_start" {
  description = "dhcp ip start of osb data plane dedicated public network"
}

variable "osb_dedicated_dhcp_end" {
  description = "dhcp ip end of osb data plane dedicated public network"
}
