# see https://github.com/terraform-providers/terraform-provider-flexibleengine/blob/master/examples/loadbalancer.tf

#allocate a floating ip, pool is external_network_name
resource "flexibleengine_networking_floatingip_v2" "internet-is-floating" {
  pool = "admin_external_net"
}


data "flexibleengine_networking_network_v2" "admin_external_net" {
  name = "admin_external_net"
}

data "openstack_networking_secgroup_v2" "tf-default-sg" {
  name        = "tf-default-sg"
}


data "openstack_networking_secgroup_v2" "default-sg" {
  name        = "default"
}


#====================================================================
# Internet https (Cloudfare only filtering)
#====================================================================

data "cloudflare_ip_ranges" "cloudflare" {}


resource "openstack_networking_secgroup_v2" "tf-internet-ha-https-sg" {
  name        = "tf-internet-ha-https-sg"
  description = "Internet HA https (via Cloudflare) access security group"
  region      = "${var.region_name}"
}

# Iterate over cloudflare edge node cidr blocks, on rule per block.

resource "openstack_networking_secgroup_rule_v2" "tf-internet-ha-https-sg-rule" {
  count = "${length(data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks)}"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "${data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks[count.index]}"
   security_group_id = "${openstack_networking_secgroup_v2.tf-internet-ha-https-sg.id}"
}

resource "flexibleengine_lb_loadbalancer_v2" "lbaas_loadbalancer_internet_relay" {
  name                  = "internet-relay-loadbalancer"
  vip_subnet_id         = "${openstack_networking_subnet_v2.tf-is-subnet.id}"
  security_group_ids = ["${data.openstack_networking_secgroup_v2.tf-default-sg.id}",
                        "${data.openstack_networking_secgroup_v2.default-sg.id}", 
                         "${openstack_networking_secgroup_v2.tf-internet-ha-https-sg.id}" ]
}

# EIP static
resource "flexibleengine_networking_floatingip_associate_v2" "lbaas_loadbalancer_association_internet_relay" {
  floating_ip = "${flexibleengine_networking_floatingip_v2.internet-is-floating.address}"
  port_id = "${flexibleengine_lb_loadbalancer_v2.lbaas_loadbalancer_internet_relay.vip_port_id}"
}

resource "flexibleengine_lb_listener_v2" "lbaas_listener_internet_relay_https" {
  name            = "internet Relay Listener HTTPS"
  protocol         = "TCP"
  protocol_port    = 443
  loadbalancer_id = "${flexibleengine_lb_loadbalancer_v2.lbaas_loadbalancer_internet_relay.id}"
  admin_state_up   = "true"
}

resource "flexibleengine_lb_pool_v2" "lbaas_pool_internet_relay_https" {
  name        = "internet-rp-pool"  #this name must match vm_extension lb name
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${flexibleengine_lb_listener_v2.lbaas_listener_internet_relay_https.id}"
  }


resource "flexibleengine_lb_monitor_v2" "lbaas_monitor_pool_internet_relay_https" {
  name = "internet-rp-monitor"
  pool_id     = "${flexibleengine_lb_pool_v2.lbaas_pool_internet_relay_https.id}"
  type        = "TCP"
  delay       = 20
  timeout     = 5
  max_retries = 5

}
