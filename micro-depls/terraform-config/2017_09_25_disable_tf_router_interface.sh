#!/bin/bash

# Set up prereqs: install locally terraform, or log on to bosh cli (currently running terraform 0.9.8)
cd $PAAS_SECRETS_GIT_REPO
cd micro-depls/terraform-config/

#Identify impacted resources to move
# IMPACTED_RESOURCES=$(cd $PAAS_TEMPLATE_GIT_REPO; grep -rin 'openstack_networking_router_interface_v2.'| grep '.tf:' | cut -d\" -f 4)
IMPACTED_RESOURCES="tf-net-expe-router-interface tf_router_interface_bosh2 tf-net-exchange-router-interface tf_router_interface_compilation tf-apps-dev-router-interface tf-cf-diego-router-interface tf-services-router-interface tf-services-2-router-interface tf-net-ondemand-router-interface tf-net-ondemand-swisscom-router-interface tf-net-exchange-no-cloud-config-router-interface tf-cf-diego-internet-router-interface"

for r in $IMPACTED_RESOURCES; do
    terraform state mv -state-out=cloudwatt-unsupported-resources.tfstate openstack_networking_router_interface_v2.$r openstack_networking_router_interface_v2.$r
done;

git add cloudwatt-unsupported-resources.tfstate
git add terraform.tfstate
git commit -m "moving openstack_networking_router_interface_v2 out of tfstate"