bosh int isolation-segment-internet.yml \
--vars-file=mapping-to-cf-vars.yml \
-o 0-rename-network-and-deployment-operators.yml \
-o 1-patch-persistent-isolation-segment-diego-cell-operators.yml \
-o 1-patch-persistent-isolation-segment-router-operators.yml \
-o 1-patch-persistent-isolation-segment-tcp-router-operators.yml \
-o 2-patch-smoke-tests-operators.yml \
-o 2-meta-env-context-patch-operators.yml \
-o 2-prune-unused-jobs-operators.yml \
-o 5-force-concourse-release-versions-operators.yml  \
-o openstack-hws/6-tcp-routes-dedicated-internet-relay-operators.yml  \

#mapping-to-cf-vars.yml \
#local-vars-tpl.yml \
