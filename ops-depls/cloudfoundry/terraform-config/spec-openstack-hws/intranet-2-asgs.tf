#is intranet 2 required ASG / cf security groups


#--- Intranet interco 2 apps relay ip
data "credhub_value" "intranet_2_apps_relay_ip" {
  name = "/secrets/intranet_interco_2/apps"
}

#--- Intranet interco 2 to_intranet
data "credhub_value" "intranet_2_to_intranet_ip" {
  name = "/secrets/intranet_interco_2/to_intranet"
}



#enable diego-cell level outbound access
resource "cloudfoundry_sec_group" "sec_group_intranet_2" {
  name = "sec_group_intranet_2"
  on_staging = false
  on_running = false
  rules {
    protocol = "tcp"
    destination = "${data.credhub_value.intranet_2_apps_relay_ip.value}"
    ports = "80"
    log = true
    description = "access to intranet 2 http"
  }
  rules {
    protocol = "tcp"
    destination = "${data.credhub_value.intranet_2_apps_relay_ip.value}"
	ports = "443"
    log = true
    description = "access to intranet 2 https"
  }

  rules {
    protocol = "tcp"
    destination = "${data.credhub_value.intranet_2_to_intranet_ip.value}"
	ports = "3128"
    log = true
    description = "access to intranet 2 http proxy"
  }
  
}

