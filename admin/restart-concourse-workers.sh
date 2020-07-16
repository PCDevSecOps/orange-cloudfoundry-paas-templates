#!/bin/bash
#===========================================================================
# Restart concourse workers 
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Script properties
export BOSH_CLIENT="admin"
export BOSH_ENVIRONMENT="192.168.10.10"

#--- Log to micro-bosh director
clear
printf "\n%bLog to micro-bosh director...%b\n" "${REVERSE}${YELLOW}" "${STD}"
logToCredhub
CREDHUB_PROPERTIES="$(credhub f -j | jq -r '.credentials[].name')"
PASSWORD="/secrets/bosh_admin_password"
flag=$(echo "${CREDHUB_PROPERTIES}" | grep "${PASSWORD}")

if [ "${flag}" = "" ] ; then
  printf "\n%bERROR: Admin password \"${PASSWORD}\" unknown.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
else
  export BOSH_CLIENT_SECRET="$(credhub g -n ${PASSWORD} | grep 'value:' | awk '{print $2}')"
  bosh alias-env micro-bosh > /dev/null 2>&1
  bosh logout > /dev/null 2>&1
  bosh -n log-in > /dev/null 2>&1
  if [ $? = 1 ] ; then
    printf "\n%bERROR: Log to \"micro-bosh\" director failed.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
  fi
fi

#--- Restart concourse workers
printf "\n%bRestart concourse workers (y/n) ? :%b " "${REVERSE}${GREEN}" "${STD}"
read choice
printf "\n"
if [ "${choice}" != "y" ] ; then
  exit 1
fi

printf "%bRestart concourse workers...%b" "${REVERSE}${YELLOW}" "${STD}"
for worker in $(bosh -d concourse vms | grep worker | awk '{print $1}') ; do
  printf "\n%b- Restart \"${worker}\"..." "${STD}"
  bosh -d concourse ssh ${worker} -c "sudo shutdown -r now" > /dev/null 2>&1
done

#--- Prune stalled concourse workers
printf "\n\n%bPrune stalled concourse workers...%b\n" "${REVERSE}${YELLOW}" "${STD}"
FLY_ENDPOINT="${FLY_ENDPOINT:-https://elpaaso-concourse.${OPS_DOMAIN}}"
export FLY_USER=$(getValue ${FLY_CREDENTIALS} "/concourse-micro-depls-username")
export FLY_PWD=$(getValue ${FLY_CREDENTIALS} "/concourse-micro-depls-password")
fly -t concourse login -c ${FLY_ENDPOINT} -k -u ${FLY_USER} -p ${FLY_PWD} > /dev/null 2>&1
fly -t concourse prune-worker -a > /dev/null 2>&1
fly -t concourse workers

printf "\n\n%bConcourse resources may be unavailable for a short time in web user interface.\nJust wait till they come back.%b\n\n" "${YELLOW}" "${STD}"