#!/bin/bash
#=================================================================================================================
# Clean static routes and disable src/target ip check on openstack ports for vpn instances
# Note:
# - Use log-openstack before
# - Need to triger terraform "approve-and-enforce-terraform-consistency" concourse job after runing the script
#=================================================================================================================
#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Check if connected
alias openstack='openstack --insecure'
openstack network list > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n%bERROR: You must \"log-openstack\" before using this script.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Clone secrets
printf "\n%bPull \"${SECRETS_REPO_DIR}\" repository...\n" "${REVERSE}${YELLOW}" "${STD}"
cd ${SECRETS_REPO_DIR}
git pull --rebase
if [ $? != 0 ] ; then
  printf "\n%bERROR: Failed to pull \"${SECRETS_REPO_DIR}\" repository.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Clean static routes on vpn terraform state
cleanTerraformState() {
  for depls in ${TERRAFORM_DEPLS} ; do
    printf "\n%bClean \"${depls}\" terraform static routes on openstack vpn instances...\n%b" "${REVERSE}${YELLOW}" "${STD}"
    cd ~/bosh/secrets/${depls}/terraform-config
    properties="$(terraform state list | grep "static-route")"
    if [ "${properties}" != "" ] ; then
      for propertie in ${properties} ; do
        printf "%b- Clean terraform \"${propertie}\"...%b\n" "${YELLOW}" "${STD}"
        terraform state rm ${propertie}
      done
    fi
  done
}

#--- disable src/target ip check on openstack ports
disableIpCheck(){
  printf "\n%bDisable src/target ip check on vpn instances...%b" "${REVERSE}${YELLOW}" "${STD}"
  PORTS="$(openstack port list | grep -E "$1" | awk '{print $2 " "}')"
  for port in ${PORTS} ; do
    printf "\n- Disable src/dest ip check on port \"${port}\"..."
    result="$(openstack port set --allowed-address ip-address=1.1.1.1/0 ${port} 2>&1)"
    result="$(openstack port show ${port} | grep "allowed_address_pairs" | grep "1.1.1.1/0")"
    if [ "${result}" = "" ] ; then
      printf "%b Not disabled%b" "${RED}" "${STD}"
    else
      printf "%b Disabled%b" "${GREEN}" "${STD}"
    fi
  done
}

#--- Clean terraform static routes
logToCredhub
getCredhubValue "SITE" "/secrets/site"

if [ "${SITE}" = "fe-int" ] ; then
  TERRAFORM_DEPLS="master-depls remote-r2-depls remote-r3-depls"
  IPS_LIST="192.168.99.45|192.168.117.41|192.168.118.41"
else
  TERRAFORM_DEPLS="remote-r3-depls"
  IPS_LIST="192.168.118.41"
fi

cleanTerraformState
commitGit "${SECRETS_REPO_DIR}" "clean_old_static_routes_on_vpn"

#--- Disable ip check on interfaces
disableIpCheck "${IPS_LIST}"

printf "\n\n%bYou have to check \"check-terraform-consistency\" concourse job uses secrets commit\nthen trigger \"approve-and-enforce-terraform-consistency\" concourse job\nfor \"${TERRAFORM_DEPLS}\".\n%b" "${REVERSE}${GREEN}" "${STD}"