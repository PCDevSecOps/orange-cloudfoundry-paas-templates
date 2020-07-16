# variables of the osb data plane shared public network
variable "osb_shared_cidr" {
  description = "CIDR/Range of osb data plane shared public network"
}

variable "osb_shared_gateway_ip" {
  description = "gateway_ip of osb data plane shared public network"
}

variable "osb_shared_dhcp_start" {
  description = "dhcp ip start of osb data plane shared public network"
}

variable "osb_shared_dhcp_end" {
  description = "dhcp ip end of osb data plane shared public network"
}
