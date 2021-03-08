#!/bin/bash

usage() {
  echo "USAGE:"
  echo "  $(basename -- $0) [OPTIONS]:"
  echo "ops-domain value : for example for PROD it is ops-data-serv.xxx.yyy"
  exit 1
}

if [ "$#" -gt 0 ] ; then
  deployments=$(bosh deployments --column=Name | grep -vE "^Name$|^Succeeded$|^[0-9]* deployments$" > deployments.lst)
  SHIELD_CORE=sandbox
  ops_domain=$1
  for deployment in $(cat deployments.lst); do
    echo "unlocking ${deployment}"
    shield api -k https://shield-webui-${deployment}.${ops_domain} sandbox
    shield login -u admin -p shield
    shield --core ${SHIELD_CORE} unlock --master shield
  done
fi
