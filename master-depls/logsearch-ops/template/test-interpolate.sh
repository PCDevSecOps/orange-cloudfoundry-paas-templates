#!/bin/bash

bosh int \
logsearch-ops.yml \
-o 0-cloudfoundry-operators.yml \
-o 0-enable-router-operators.yml \
-o 1-bosh-dns-aliases-operators.yml \
-o 1-cerebro-operators.yml \
-o 1-increase-recovery-timeout-operators.yml \
-o 1-ingestors-heap-size-operators.yml  \
-o 1-instances-counts-operators.yml \
-o 1-networks-operators.yml \
-o 1-scale-to-two-azs-operators.yml  \
-o 2-vm-types-operators.yml \
-o 2-vrrp-operators.yml \
-o 5-change-disk-type-operators.yml \
-o 5-use-latest-release-operators.yml \
-o 8-add-oauth2-proxy-bosh-release-operators.yml  \
-o 9-force-bionic-operators.yml  \
-o curator-tuning-operators.yml \
--vars-file=1-vm-types-vars-tpl.yml \
--vars-file=1-instances-counts-vars-tpl.yml  \
--vars-file=logsearch-vars.yml  \
--vars-file=curator-tuning-vars-tpl.yml \


exit 0

-o 6-scripting-operators.yml  \


-o 1-bosh-dns-aliases-operators.yml \
-o 1-cerebro-operators.yml  \
-o 1-increase-recovery-timeout-operators.yml \ 
-o 1-ingestors-custom-filters-operators.yml  \
-o 1-ingestors-heap-size-operators.yml  \
-o 1-instances-counts-operators.yml  \
-o 1-networks-operators.yml  \
-o 1-scale-to-two-azs-operators.yml \ 
-o 1-scripting-operators.yml  \
-o 2-vm-types-operators.yml  \
-o 2-vrrp-operators.yml  \
-o 8-add-oauth2-proxy-bosh-release-operators.yml \ 
-o 9-force-bionic-operators.yml  \
-o curator-tuning-operators.yml  \
-o vm-extensions-operators.yml \




exit

-o 1-kibana-tuning-operators.yml  \
-o 1-persistent-disk-types-operators.yml  \
-o 1-stemcell-version-operators.yml  \


-o 1-set-logsearch-url-operators.yml  \

-o 9-decouple-from-cf-operators.yml  \
9-ls-router-operators.yml
feature-logsearch-bionic-adaptation
feature-logsearch-bionic-adaptation
