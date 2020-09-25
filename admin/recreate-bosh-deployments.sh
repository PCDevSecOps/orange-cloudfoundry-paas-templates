#!/bin/bash
#===========================================================================
# Recreate all bosh deployments managed by a specific bosh director 
# except "docker-bosh-cli" which is used to run the script, and
# "cfcr" which can't be currently recreated
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Script properties
FLAG_ERROR=0 ; DIRECTORS=""

#--- Check scripts options
usage() {
  printf "\n%bUSAGE:" "${RED}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-40s %s" "--all, -a" "Recreate deployments on each bosh-directors"
  printf "\n  %-40s %s" "--directors, -d \"bosh-directors\"" "Bosh-directors \"space separated\" (${BOSH_DIRECTORS})"
  printf "%b\n\n" "${STD}"
  exit 1
}

#--- Check options
if [ "$#" = 0 ] ; then
  usage
fi

while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-a"|"--all")
      DIRECTORS="${BOSH_DIRECTORS}" ; shift ;;

    "-d"|"--directors")
        DIRECTORS="$2"
        for director in ${DIRECTORS} ; do
          flag="$(echo " ${BOSH_DIRECTORS} " | grep " ${director} ")"
          if [ "${flag}" = "" ] ; then
            usage
          fi
        done
        shift ; shift ;;
    *) usage ;;
  esac
done

#--- Confirm recreation
printf "\n%bRecreate \"${DIRECTORS}\" deployments (y/[n]) ? :%b " "${REVERSE}${GREEN}" "${STD}" ; read choice
printf "\n"
if [ "${choice}" != "y" ] ; then
  exit
fi

#--- Receate deployments in each bosh directors
clear
for bosh_director in ${DIRECTORS} ; do
  #--- Collect active bosh deployments for selected root director
  printf "\n\n%bRecreate \"${bosh_director}\" deployments...%b\n" "${REVERSE}${YELLOW}" "${STD}"
  logToBosh "${bosh_director}"
  if [ $? = 1 ] ; then
    exit 1
  fi

  #--- Recreate bosh deployment
  active_bosh_deployments=$(bosh deployments --json | jq -r '.Tables[].Rows[].name' | grep -vE "docker-bosh-cli|cfcr$")

  for deployment in ${active_bosh_deployments} ; do
    printf "\n- Recreate \"${deployment}\" deployment..."
    bosh -d ${deployment} -n recreate --max-in-flight=1 > /dev/null 2>&1
    if [ $? != 0 ] ; then
      printf " %bfailed%b" "${RED}" "${STD}" ; FLAG_ERROR=1
    else
      printf " %bdone%b" "${GREEN}" "${STD}"
    fi
  done
done

if [ ${FLAG_ERROR} = 0 ] ; then
  printf "\n\n%bDeployments have been recreated successfully%b\n\n" "${GREEN}" "${STD}"
else
  printf "\n\n%bERROR: Some deployments failed to recreate.%b\n\n" "${RED}" "${STD}" ; exit 1
fi