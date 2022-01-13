#!/bin/bash
#===========================================================================
# Check vpn probes with multi-region configuration
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Check probe with http request and iperf analysis
checkProbe() {
  TARGET_REGION="$1"
  TARGET_IP="$2"
  printf "\n%b\"${TARGET_REGION}\" vpn probe analysis...%b\n\n" "${REVERSE}${YELLOW}" "${STD}"
  status="$(curl -w %{http_code} --connect-timeout 2 -o /dev/null -s http://${TARGET_IP})"
  if [ "${status}" != "200" ] ; then
    printf "%bERROR: Could not join \"${TARGET_REGION}\" vpn probe (http ${status})%b\n" "${RED}" "${STD}"
  else
    iperf3 -c ${TARGET_IP} --bidir -t 4 -f m
  fi
}

#--- Log to a specific bosh director
clear
unset BOSH_DEPLOYMENT
selectBoshDirector "coab"

#--- Get vpn-probes ips
BOSH_PROBE_PROPERTIES="$(bosh -d "vpn-probe" is --json)"
IP_R2="$(echo "${BOSH_PROBE_PROPERTIES}" | jq -r '.Tables[].Rows[]|select(.az == "r2-z1")|.ips')"
IP_R3="$(echo "${BOSH_PROBE_PROPERTIES}" | jq -r '.Tables[].Rows[]|select(.az == "r3-z1")|.ips')"

#--- Check probes
checkProbe "R2" "${IP_R2}"
checkProbe "R3" "${IP_R3}"

printf "\n"