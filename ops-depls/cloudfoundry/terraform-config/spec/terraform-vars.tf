variable "cloudfoundry" {
  type = "map"
  description = "All cloudfoundry related shared vars"
}

# variables of the osb data plane shared public network
variable "osb_shared_destination" {
  description = "CIDR/Range of osb data plane shared public network"
}

