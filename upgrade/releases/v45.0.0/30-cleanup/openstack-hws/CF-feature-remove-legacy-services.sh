#!/bin/sh

echo "Params: $*"
CONFIG_DIR="$1"

cf target -o system_domain -s fpv-brokers

for broker_app in fpv-internet-broker fpv-internet-sec-group-broker-filter;do
    BROKER_COUNT=$(cf a|grep "${broker_app}"|wc -l)
    if [ $BROKER_COUNT -eq 1 ];then
        cf delete "${broker_app}" -f
    else
       echo "SKIPPING, ${broker_app} does not exist"
    fi
done


