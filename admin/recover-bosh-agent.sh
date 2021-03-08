#!/bin/bash
#===========================================================================
# Recover bosh agent deployments with "unresponsive agent" status
# for a selected bosh director (use "log-bosh" before)
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Log to a specific bosh director
clear
unset BOSH_DEPLOYMENT
selectBoshDirector

printf "\n%bCollect \"${BOSH_DIRECTOR_NAME}\" instances details (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"

#--- Check deployments with "unresponsive agent" vms status
unresponsive_deployments=$(bosh is --json | jq -r '.Tables[].Rows[]|select(.process_state == "unresponsive agent")|.deployment' | uniq)

#--- Check deployments with resurrector "scan and fix" or "apply resolutions" active task
resurrector_deployments="$(bosh tasks --json | jq -r '.Tables[].Rows[]|select(.description == "scan and fix" or .description == "apply resolutions")|.deployment' | uniq)"

#--- Filter active tasks
for deployment in ${resurrector_deployments} ; do
  unresponsive_deployments="$(echo "${unresponsive_deployments}" | sed -e "/${deployment}$/d")"
done

if [ "${unresponsive_deployments}" = "" ] ; then
  printf "\n%bNo deployment with \"unresponsive agent\" status.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Select bosh deployments to recover
printf "\n%bDeployments to recover :%b\n%s" "${REVERSE}${GREEN}" "${STD}" "${unresponsive_deployments}"
printf "\n\n%bYour choice (list space separated or <Enter> to select all) :%b " "${REVERSE}${GREEN}" "${STD}" ; read choice
if [ "${choice}" = "" ] ; then
  selected_deployments="$(echo "${unresponsive_deployments}" | tr '\n' ' ')"
else
  selected_deployments="${choice}"
  for item in ${selected_deployments} ; do
    result=$(echo "${unresponsive_deployments}" | grep "${item}")
    if [ "${result}" = "" ] ; then
      printf "\n%bERROR: Deployment \"${choice}\" unknown.%b\n\n" "${RED}" "${STD}" ; exit 1
    fi
  done
fi

#--- Recover vms from selected deployments
printf "\n%bSet resurrector off...%b\n" "${REVERSE}${YELLOW}" "${STD}"
bosh update-resurrection off > /dev/null 2>&1

printf "\n%bRecover vms with \"unresponsive agent\" status...%b\n" "${REVERSE}${YELLOW}" "${STD}"
for BOSH_DEPLOYMENT in ${selected_deployments} ; do
  export BOSH_DEPLOYMENT
  printf "\n%b- Recover \"${BOSH_DEPLOYMENT}\"..." "${STD}"
  nohup bosh -n cck --resolution=recreate_vm_without_wait > /dev/null 2>&1 &
done

#--- Wait end of nohup bosh operations
printf "\n\n"
loop=1
while [ ${loop} = 1 ] ; do
  nb_todo=$(ps -ef | grep "bosh -n cck --resolution=recreate_vm_without_wait" | grep -cv "grep")
  printf "\r%b$(date) : stay %b${nb_todo}%b deployments to end...%b" "${REVERSE}${YELLOW}" "${BLINK}" "${STD}${REVERSE}${YELLOW}" "${STD}"
  if [ "${nb_todo}" = "0" ] ; then
    printf "\r                                                                        " ; loop=0
  else
    sleep 10
  fi
done

#--- Display unresponsive deployments (if exists)
unset BOSH_DEPLOYMENT
printf "\n%bCollect \"${BOSH_DIRECTOR_NAME}\" unresponsive instances (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"
unresponsive_deployments=$(bosh is --json | jq -r '.Tables[].Rows[]|select(.process_state == "unresponsive agent")|.deployment + "|" + .instance')

if [ "${unresponsive_deployments}" = "" ] ; then
  printf "\n%bNo unresponsive instances.%b\n" "${YELLOW}" "${STD}"
  printf "\n%bSet resurrector on...%b\n" "${REVERSE}${YELLOW}" "${STD}"
  bosh update-resurrection on > /dev/null 2>&1
else
  printf "\n%bUnresponsive instances...%b\n%s" "${REVERSE}${YELLOW}" "${STD}"
  printf "\n%-20s %-42s" "Deployment" "Instance"
  for item in ${unresponsive_deployments} ; do
    deployment="$(echo "${item}" | awk -F "|" '{print $1}')"
    instance="$(echo "${item}" | awk -F "|" '{print $2}')"
    printf "\n%-20s %b%s%b" "${deployment}" "${RED}" "${instance}" "${STD}"
  done

  #--- Confirm resurrector reactivation (need to set off if multiple processing)
  printf "\n\n%bSet resurrector on (y/[n]) ? :%b " "${REVERSE}${GREEN}" "${STD}" ; read choice
  if [ "${choice}" = "y" ] ; then
    printf "\n%bSet resurrector on...%b\n" "${REVERSE}${YELLOW}" "${STD}"
    bosh update-resurrection on > /dev/null 2>&1
  else
    printf "\n%bCare: Resurrector is off...%b" "${BLINK}${YELLOW}" "${STD}"
  fi
fi

printf "\n\n"