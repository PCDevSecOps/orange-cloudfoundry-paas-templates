#!/bin/bash

CONFIG_DIR=$1

#Browse credhub and clean shield-ca and shield-tls entries for coab-depls
#i will store /bosh-coab/y_f25d6f30-3366-4f26-81e1-43138a988fe4/shield-ca
#variable will store shield-ca
for i in $(credhub find | grep /bosh-coab | awk '{ print $3 }'); do
    variable=`echo $i | awk -F "/" '{ print $4 }'`;
    if [ "${variable}" = "shield-ca" ]; then
    	echo "deleting ${i}"
        credhub delete -n "${i}"
    elif [ "${variable}" = "shield-tls" ]; then
    	echo "deleting ${i}"
        credhub delete -n "${i}"
    else
    	echo "skipping ${i}"
    fi
done

