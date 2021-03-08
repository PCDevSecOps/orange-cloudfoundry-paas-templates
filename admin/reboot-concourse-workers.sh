#!/bin/bash
#===========================================================================
# Reboot concourse workers 
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Log to micro-bosh director
clear
printf "\n%bLog to micro-bosh director...%b\n" "${REVERSE}${YELLOW}" "${STD}"
logToBosh "micro-bosh"
if [ $? = 1 ] ; then
  exit 1
fi

#--- Reboot concourse workers
printf "\n%bReboot concourse workers (y/[n]) ? :%b " "${REVERSE}${GREEN}" "${STD}"
read choice
printf "\n"
if [ "${choice}" != "y" ] ; then
  exit 1
fi

printf "%bReboot concourse workers...%b" "${REVERSE}${YELLOW}" "${STD}"
for worker in $(bosh -d concourse vms | grep worker | awk '{print $1}') ; do
  printf "\n%b- Reboot \"${worker}\"..." "${STD}"
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