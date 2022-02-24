#--- Intranet https access security group
data "openstack_networking_secgroup_v2" "tf-intranet-http-sg" {
  name        = "tf-intranet-http-sg"
}

data "openstack_networking_secgroup_v2" "default-sg" {
  name        = "default"
}

data "openstack_networking_secgroup_v2" "tf-default-sg" {
  name        = "tf-default-sg"
}


#----Public ops vip
data "credhub_value" "ops_vip" {
  name = "/secrets/multi_region_region_1_intranet_interco_ops"
}


resource "flexibleengine_lb_loadbalancer_v2" "ops_lb" {
  name                  = "ops-lb"
  vip_subnet_id         =  openstack_networking_subnet_v2.tf_subnet_intranet_interco_r1.id
  vip_address           = data.credhub_value.ops_vip.value
  security_group_ids = [ data.openstack_networking_secgroup_v2.tf-default-sg.id,
                         data.openstack_networking_secgroup_v2.default-sg.id, 
                         data.openstack_networking_secgroup_v2.tf-intranet-http-sg.id ]

}

resource "flexibleengine_lb_listener_v2" "ops_lb_listener_https" {
  name            = "ops-lb-listener-https"
  protocol         = "TCP"
  protocol_port    = 443
  loadbalancer_id = flexibleengine_lb_loadbalancer_v2.ops_lb.id
  admin_state_up   = "true"
}

resource "flexibleengine_lb_pool_v2" "ops_lb_pool_https" {
  name        = "ops-lb-pool-https"  #this name must match vm_extension lb name
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = flexibleengine_lb_listener_v2.ops_lb_listener_https.id
  }


resource "flexibleengine_lb_monitor_v2" "ops_lb_monitor_https" {
  name = "ops-lb-monitor-https"
  pool_id     = flexibleengine_lb_pool_v2.ops_lb_pool_https.id
  type        = "TCP"
  delay       = 20
  timeout     = 5
  max_retries = 5

}
