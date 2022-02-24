#!/bin/bash
#=======================================================================================
# Recover bosh agent on instances with "unresponsive agent" status or "no jobs running"
#=======================================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Wait end of nohup bosh operations
waitNohup() {
  printf "\n\n"
  loop=1
  while [ ${loop} = 1 ] ; do
    nb_todo=$(ps -ef | grep "$1" | grep -cv "grep")
    printf "\r%b$(date) : stay %b${nb_todo}%b items to process...%b" "${REVERSE}${YELLOW}" "${BLINK}" "${STD}${REVERSE}${YELLOW}" "${STD}"
    if [ "${nb_todo}" = "0" ] ; then
      printf "\r                                                                        " ; loop=0
    else
      sleep 10
    fi
  done
}

#--- Log to a specific bosh director
clear
selectBoshDirector
unset BOSH_DEPLOYMENT
printf "\n%bCheck \"${BOSH_DIRECTOR_NAME}\" instances details (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"

#--- Check deployments with "unresponsive agent" vms status
unresponsive_deployments=$(bosh is --json | jq -r '.Tables[].Rows[]|select(.process_state == "unresponsive agent")|.deployment' | uniq)

#--- Check deployments with resurrector "scan and fix" or "apply resolutions" active task
resurrector_deployments="$(bosh tasks --json | jq -r '.Tables[].Rows[]|select(.description == "scan and fix" or .description == "apply resolutions")|.deployment' | uniq)"

#--- Filter deployments with no resurrector task running
for deployment in ${resurrector_deployments} ; do
  unresponsive_deployments="$(echo "${unresponsive_deployments}" | sed -e "/${deployment}$/d")"
done

if [ "${unresponsive_deployments}" != "" ] ; then
  #--- Disable resurrector
  printf "\n%bSet resurrector off...%b\n" "${REVERSE}${YELLOW}" "${STD}"
  bosh update-resurrection off > /dev/null 2>&1

  #--- Recover unresponsive vms
  printf "\n%bRecover vms with \"unresponsive agent\" status...%b" "${REVERSE}${YELLOW}" "${STD}"
  for BOSH_DEPLOYMENT in ${unresponsive_deployments} ; do
    export BOSH_DEPLOYMENT
    printf "\n%b- Recover \"${BOSH_DEPLOYMENT}\"..." "${STD}"
    nohup bosh -n cck --resolution=recreate_vm_without_wait > /dev/null 2>&1 &
  done

  #--- Wait end of nohup bosh operations
  waitNohup "bosh -n cck --resolution=recreate_vm_without_wait"

  #--- Enable resurrector
  printf "\n%bSet resurrector on...%b\n" "${REVERSE}${YELLOW}" "${STD}"
  bosh update-resurrection on > /dev/null 2>&1
fi

#--- Check vms with no jobs running (bosh issue)
instance_properties=$(echo "${deployments_status}" | jq -r '.Tables[].Rows[]|select(.process_state == "")|select(.ips != "")|.deployment + "|" + .instance')
if [ "${instance_properties}" != "" ] ; then
  printf "\n%bRecover vms with no jobs running...%b" "${REVERSE}${YELLOW}" "${STD}"
  for properties in ${instance_properties} ; do
    export BOSH_DEPLOYMENT="$(echo "${properties}" | awk -F "|" '{print $1}')"
    instance_id="$(echo "${properties}" | awk -F "|" '{print $2}')"
    printf "\n%b- Recover \"${BOSH_DEPLOYMENT}:${instance_id}\"..." "${STD}"
    nohup bosh -n restart ${instance} > /dev/null 2>&1 &
  done

  #--- Wait end of nohup bosh operations
  waitNohup "bosh -n restart"
fi

#--- Check process result
unset BOSH_DEPLOYMENT
printf "\n%bCheck \"${BOSH_DIRECTOR_NAME}\" instances details (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"
deployments_status="$(bosh is --json)"

unresponsive_deployments=$(echo "${deployments_status}" | jq -r '.Tables[].Rows[]|select(.process_state == "unresponsive agent")|.deployment' | uniq)
for deployment in ${unresponsive_deployments} ; do
  printf "\n%b- \"${deployment}\" with \"unresponsive agent\"" "${STD}"
done

instance_properties=$(echo "${deployments_status}" | jq -r '.Tables[].Rows[]|select(.process_state == "")|select(.ips != "")|.deployment + "|" + .instance')
for properties in ${instance_properties} ; do
  deployment="$(echo "${properties}" | awk -F "|" '{print $1}')"
  instance_id="$(echo "${properties}" | awk -F "|" '{print $2}')"
  printf "\n%b- \"${deployment}:${instance_id}\" with \"no running jobs\"" "${STD}"
done

printf "\n\n"