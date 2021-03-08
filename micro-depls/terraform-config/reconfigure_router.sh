#!/bin/sh
# a script to reapply internet connection of the public router
# known cloudwatt bug
# terraform cant detect the error.
router_id=d618bb65-168d-455b-b141-2ca98d6f345e
public_net_id=6ea98324-0f14-49f6-97c0-885d1b8dc517
neutron router-list |grep $router_id
neutron net-list |grep $public_net_id
neutron router-gateway-clear ${router_id}
neutron router-gateway-set ${router_id} ${public_net_id}


