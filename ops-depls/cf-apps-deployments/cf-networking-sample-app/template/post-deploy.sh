#!/bin/bash

API_OPTIONS="--skip-ssl-validation"

set -e

cf api "$CF_API_URL" $API_OPTIONS
cf auth "$CF_USERNAME" "$CF_PASSWORD"

cf target -o "$CF_ORG" -s "$CF_SPACE"

echo "Getting deployed apps"
deployed_apps=$(cf apps|grep -E "^cf-"|cut -d' ' -f1)
echo "Apps found: $deployed_apps"
deployed_apps_count=$(echo $deployed_apps|wc -w)

if [ $deployed_apps_count -ge 2 ]; then
  cf add-network-policy cf-networking-sample-frontend cf-networking-sample-backend-a --port 7007 --protocol tcp
  cf add-network-policy cf-networking-sample-frontend cf-networking-sample-backend-a --port 9003 --protocol udp
  echo "================="
fi

echo "Testing using cf ssh"
cf allow-space-ssh "$CF_SPACE"
set -x
cf ssh cf-networking-sample-backend-a -c 'curl -sSL backend-a.apps.internal:7007 >/dev/null'
cf ssh cf-networking-sample-frontend -c 'curl -sSL backend-a.apps.internal:7007 >/dev/null'
set +x
cf disallow-space-ssh "$CF_SPACE"
echo "================="

set +e
frontend_routes=$(cf app cf-networking-sample-frontend|grep -E "^routes:"|cut -d':' -f2-|cut -c13-)
frontend_first_route=$(echo $frontend_routes|cut -d',' -f1)
if [[ $? -ne 0 || -z "$frontend_first_route" ]]; then
  echo "Error: invalid frontend_first_route: $frontend_first_route"
  echo "Debug info: frontend_routes: $frontend_routes"
  exit 1
fi
echo "Testing using frontend: $frontend_first_route"
failure=0
export no_proxy=$no_proxy,$frontend_first_route
CURL_CMD="curl -sSL -k \"https://$frontend_first_route/proxy/?url=backend-a.apps.internal%3A7007\""
echo "================="

echo "Executing $CURL_CMD"
tcp_check_count=$(eval $CURL_CMD| grep "Hello from the backend, here is a picture of a cat"|wc -l)
if [ $tcp_check_count -ne 1 ];then
  echo "Failed to connect to $frontend_first_route in TCP"
  failure=1
else
  echo "TCP is OK"
fi
echo "================="

CURL_CMD="curl -sSL -k \"https://$frontend_first_route/udp-test/?url=backend-a.apps.internal%3A9003&message=Orange+is+back\""
echo "Executing $CURL_CMD"
udp_check_count=$(eval $CURL_CMD| grep "ORANGE IS BACK"|wc -l)
if [ $udp_check_count -ne 1 ];then
  echo "Failed to connect to $frontend_first_route in UDP"
  failure=1
else
  echo "UDP is OK"
fi
echo "================="

echo "Checking network policies"
cf network-policies
network_policies=$(cf network-policies|grep -E "^cf-networking-sample-frontend"|cut -d' ' -f1)
echo "Network policies found: $network_policies"
network_policies_count=$(echo $network_policies|wc -w)
if [ $network_policies_count -ne 2 ]; then
  echo
  echo "Unexpected network policies detected (network_policies_count: $network_policies_count). Expecting only 2 network policies, like those below:"
  echo "cf-networking-sample-frontend   cf-networking-sample-backend-a   tcp        7007    cf-networking-sample-app   system_domain"
  echo "cf-networking-sample-frontend   cf-networking-sample-backend-a   udp        9003    cf-networking-sample-app   system_domain"
  failure=1
else
  echo "Network policies are ok"
fi

if [ $failure -ne 0 ];then
  echo "Error detected, please check !"
  exit 1
fi

