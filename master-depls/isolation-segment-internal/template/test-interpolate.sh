bosh int isolation-segment-internal.yml \
--vars-file=mapping-to-cf-vars.yml \
-o 0-rename-network-and-deployment-operators.yml \
-o 1-patch-persistent-isolation-segment-diego-cell-operators.yml \
-o 1-patch-persistent-isolation-segment-router-operators.yml \
-o 2-meta-env-context-patch-operators.yml \
-o 2-prune-unused-jobs-operators.yml \
-o 5-force-concourse-release-versions-operators.yml  \
-o 6-inboud-traffic-operators.yml \

#mapping-to-cf-vars.yml \
#local-vars-tpl.yml \
#
#-o 7-outbound-traffic-operators.yml \
#
#-o 8-outbound-traffic-bosh-dns-recursor-operators.yml \

#-o 8-outbound-traffic-squid-operators.yml \
