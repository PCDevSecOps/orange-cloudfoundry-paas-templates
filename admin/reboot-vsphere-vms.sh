#!/bin/bash
#=================================================================================
# Reboot vsphere vms on selected region (when guest file systems become read only)
# To use from local laptop environment
#=================================================================================

#--- Clis versions
BOSH_CLI_VERSION="6.4.3"
GOVC_VERSION="0.26.0"

#--- Time wait (seconds) between next vm reboot
WAIT_TIME=40

#--- Deployments to reboot in priority (others deployments will be processed on next step)
PRIORITIZED_MICRO_DEPLS="00-core-connectivity-k8s|01-ci-k8s|credhub-ha|bosh-master|dns-recursor|docker-bosh-cli|inception|internet-proxy"
PRIORITIZED_MASTER_DEPLS="bosh-coab|bosh-ops|bosh-remote-r2|bosh-remote-r3|cloudfoundry-datastores|intranet-interco-relay|ops-routing|r1-vpn"

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

#--- Check prerequisites
SHARED_SECRETS=~/bosh/secrets/shared/secrets.yml
if [ ! -s "${SHARED_SECRETS}" ] ; then
  printf "\n%bERROR: Credential file \"${SHARED_SECRETS}\" unknown.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Get a propertie in yaml file
getPropertie() {
  value="$(bosh int ${SHARED_SECRETS} --path $1 2> /dev/null)"
  if [ $? != 0 ] ; then
    printf "\n\n%bERROR: Propertie \"$1\" unknown.%b\n\n" "${RED}" "${STD}" >&2 ; exit 1
  else
    printf "${value}"
  fi
}

#--- Reboot bosh deployment vms
RebootDeploymentVms() {
  nb_vms=$1
  depl_vms_list="$2"

  for fields in ${depl_vms_list} ; do
    IFS=$'|' read -r depl_director depl_name depl_cid depl_vm_name <<< "${fields}"
    #--- Check if vm was reboot recently
    NOW=$(date +%s)
    vm_uptime="$(govc vm.info -json ${depl_vm_name} | jq -r '.VirtualMachines[].Summary.QuickStats.UptimeSeconds' 2> /dev/null)"
    duration=$(date -d@$(expr ${NOW} - ${BEGIN_TS}) +%s)
    if [ ${vm_uptime} -ge ${duration} ] ; then
      #--- Reboot vm
      govc vm.power -r=true -force=true ${depl_vm_name} > /dev/null 2>&1
      if [ $? = 0 ] ; then
        if [ ${nb_vms} -gt 1 ] ; then
          sleep ${WAIT_TIME}
        fi
        printf "%bOK%b \"${depl_director}/${depl_name}\" ${depl_cid} (${depl_vm_name})\n" "${GREEN}" "${STD}" >&2
      else
        printf "%bKO%b \"${depl_director}/${depl_name}\" ${depl_cid} (${depl_vm_name})\n" "${RED}" "${STD}" >&2
      fi
    fi
  done
}

#--- Reboot bosh director vms
RebootDirectorVms() {
  BEGIN_REBOOT=$(date +%s)
  priority="$1"
  director_vms_list="$2"
  cpt=1 ; deployment_vms_list=""
  printf "\n%bReboot ${priority} vms...%b\n\n" "${REVERSE}${YELLOW}" "${STD}"
  for fields in ${director_vms_list} ; do
    IFS=$'|' read -r director deployment cid name <<< "${fields}"
    nb=${DEPLS_NB_VMS[${director}|${deployment}]}
    if [ ${nb} = 1 ] ; then
      RebootDeploymentVms 1 "${fields}"
    else
      if [ ${cpt} = ${nb} ] ; then
        deployment_vms_list+=" ${fields}"
        RebootDeploymentVms ${nb} "${deployment_vms_list}" &
        pids+=" $!"
        cpt=1 ; deployment_vms_list=""
      else
        deployment_vms_list+=" ${fields}"
        (( cpt++ ))
      fi
    fi
  done

  #--- Wait end of all deployments vms
  for pid in ${pids[*]} ; do
    wait $pid
  done

  END_REBOOT=$(date +%s)
  duration=$(date -d@$(expr ${END_REBOOT} - ${BEGIN_REBOOT}) -u +%H:%M:%S)
  printf "\n%bReboot ${priority} vms duration : ${duration}%b\n" "${REVERSE}${YELLOW}" "${STD}"
}

#--- Get vms informations from vcenter
getVmsInfo() {
  region="$1"
  printf "\n%b$(date +%H:%M:%S) => Collect \"${region}\" vm informations (should take a while)...%b\n" "${BLINK}${REVERSE}${YELLOW}" "${STD}"

  #--- Log to vcenter
  case "${region}" in
    "region_1")
      GOVC_URL="$(getPropertie "/secrets/vsphere/vcenter_ip")"
      GOVC_USERNAME="$(getPropertie "/secrets/vsphere/vcenter_user")"
      GOVC_PASSWORD="$(getPropertie "/secrets/vsphere/vcenter_password")"
      GOVC_DATACENTER="$(getPropertie "/secrets/vsphere/vcenter_dc")"
      GOVC_DATASTORE="$(getPropertie "/secrets/vsphere/vcenter_ds")"
      GOVC_CLUSTER="$(getPropertie "/secrets/vsphere/vcenter_cluster")"
      GOVC_RESOURCE_POOL="$(getPropertie "/secrets/vsphere/vcenter_resource_pool")"
      GOVC_VMS_PATH="$(getPropertie "/secrets/vsphere/vcenter_vms")" ;;

    "region_2")
      GOVC_URL="$(getPropertie "/secrets/multi_region/region_2/vsphere/vcenter_ip")"
      GOVC_USERNAME="$(getPropertie "/secrets/multi_region/region_2/vsphere/vcenter_user")"
      GOVC_PASSWORD="$(getPropertie "/secrets/multi_region/region_2/vsphere/vcenter_password")"
      GOVC_DATACENTER="$(getPropertie "/secrets/multi_region/region_2/vsphere/vcenter_dc")"
      GOVC_DATASTORE="$(getPropertie "/secrets/multi_region/region_2/vsphere/vcenter_ds")"
      GOVC_CLUSTER="$(getPropertie "/secrets/multi_region/region_2/vsphere/vcenter_cluster")"
      GOVC_RESOURCE_POOL="$(getPropertie "/secrets/multi_region/region_2/vsphere/vcenter_resource_pool")"
      GOVC_VMS_PATH="$(getPropertie "/secrets/multi_region/region_2/vsphere/vcenter_vms")" ;;
  esac

  export GOVC_URL GOVC_USERNAME GOVC_PASSWORD GOVC_DATACENTER GOVC_DATASTORE GOVC_CLUSTER GOVC_RESOURCE_POOL
  export GOVC_INSECURE=1

  #--- Collect vms informations
  VM_LIST_INIT="" ; VM_LIST_MICRO="" ; VM_LIST_MASTER="" ; VM_LIST_R2=""
  VM_PATHS="$(govc find / -type m | grep "/${GOVC_DATACENTER}/vm/${GOVC_VMS_PATH}/" | grep "/vm-" | LC_ALL=C sort)"

  for path in ${VM_PATHS} ; do
    vm_name="$(echo "${path}" | sed -e "s+.*/++g")"
    vm_info="$(govc vm.info -json ${vm_name} | jq -r '.VirtualMachines[]')"
    key="$(echo "${vm_info}" | jq -r '.AvailableField[]|select(.Name == "director")|.Key')"
    vm_director="$(echo "${vm_info}" | jq -r --arg KEY "${key}" '.Value[]|select(.Key|tostring == $KEY)|.Value' 2> /dev/null)"
    if [ "${vm_director}" != "" ] ; then
      key="$(echo "${vm_info}" | jq -r '.AvailableField[]|select(.Name == "deployment")|.Key')"
      vm_deployment="$(echo "${vm_info}" | jq -r --arg KEY "${key}" '.Value[]|select(.Key|tostring == $KEY)|.Value' 2> /dev/null)"
      key="$(echo "${vm_info}" | jq -r '.AvailableField[]|select(.Name == "name")|.Key')"
      vm_cid="$(echo "${vm_info}" | jq -r --arg KEY "${key}" '.Value[]|select(.Key|tostring == $KEY)|.Value' 2> /dev/null)"
      (( DEPLS_NB_VMS["${vm_director}|${vm_deployment}"]++ ))
      vm_properties="${vm_director}|${vm_deployment}|${vm_cid}|${vm_name}"
      case "${vm_director}" in
        "bosh-init") VM_LIST_INIT+=" ${vm_properties}" ;;
        "micro-bosh") VM_LIST_MICRO+=" ${vm_properties}" ;;
        "bosh-master") VM_LIST_MASTER+=" ${vm_properties}" ;;
        "bosh-remote-r2") VM_LIST_R2+=" ${vm_properties}" ;;
      esac
    fi
  done

  #--- Reboot bosh directors prioritized deployments vms
  clear
  if [ "${region}" = "region_1" ] ; then
    PRIORITIZED_VM_LIST="$(echo "${VM_LIST_MICRO}" | sed -e "s+ +\n+g" | LC_ALL=C sort | grep -E "${PRIORITIZED_MICRO_DEPLS}")"
    PRIORITIZED_VM_LIST="${PRIORITIZED_VM_LIST} $(echo "${VM_LIST_MASTER}" | sed -e "s+ +\n+g" | LC_ALL=C sort | grep -E "${PRIORITIZED_MASTER_DEPLS}")"
    PRIORITIZED_VM_LIST="${PRIORITIZED_VM_LIST} $(echo "${VM_LIST_INIT}" | sed -e "s+ +\n+g" | LC_ALL=C sort)"
    RebootDirectorVms "prioritized" "${PRIORITIZED_VM_LIST}"

    #--- Reboot bosh directors non-prioritized deployments vms
    NON_PRIORITIZED_VM_LIST="$(echo "${VM_LIST_MICRO}" | sed -e "s+ +\n+g" | LC_ALL=C sort | grep -vE "${PRIORITIZED_MICRO_DEPLS}")"
    NON_PRIORITIZED_VM_LIST="${NON_PRIORITIZED_VM_LIST} $(echo "${VM_LIST_MASTER}" | sed -e "s+ +\n+g" | LC_ALL=C sort | grep -vE "${PRIORITIZED_MASTER_DEPLS}")"
    RebootDirectorVms "non-prioritized" "${NON_PRIORITIZED_VM_LIST}"
  else
    VM_LIST_R2="$(echo "${VM_LIST_R2}" | sed -e "s+ +\n+g" | LC_ALL=C sort)"
    RebootDirectorVms "prioritized" "${VM_LIST_R2}"
  fi
}

#--- Set prerequisites
declare -A DEPLS_NB_VMS
STATUS_FILE="/tmp/$(basename $0)_$$.res"

BIN_DIR=${HOME}/bin
if [ ! -d ${BIN_DIR} ] ; then
  mkdir ${BIN_DIR} > /dev/null 2>&1
fi
cd ${BIN_DIR}

#--- Install bosh cli (if needed)
flag=$(bosh --version 2> /dev/null | grep "${BOSH_CLI_VERSION}")
if [ "${flag}" = "" ] ; then
  printf "\n%bInstall bosh cli version \"${BOSH_CLI_VERSION}\"...%b\n" "${REVERSE}${YELLOW}" "${STD}"
  rm -f bosh > /dev/null 2>&1
  (curl -sSLo ./bosh "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSH_CLI_VERSION}-linux-amd64" 2>&1 ; echo $? > ${STATUS_FILE})
  result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
  if [ ${result} != 0 ] ; then
    printf "\n%bERROR: Install bosh cli failed.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
  else
    chmod 755 bosh
  fi
fi

#--- Install govc cli (if needed)
flag=$(govc version 2> /dev/null | grep "${GOVC_VERSION}")
if [ "${flag}" = "" ] ; then
  printf "\n%bInstall govc cli version \"${GOVC_VERSION}\"...%b\n" "${REVERSE}${YELLOW}" "${STD}"
  rm -f govc > /dev/null 2>&1
  (curl -sSL "https://github.com/vmware/govmomi/releases/download/v${GOVC_VERSION}/govc_Linux_x86_64.tar.gz" | tar -xz -C . ; echo $? > ${STATUS_FILE})
  result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
  if [ ${result} != 0 ] ; then
    printf "\n%bERROR: Install govc cli failed.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
  else
    chmod 755 govc
  fi
fi
rm -f *.txt *.md > /dev/null 2>&1

#--- Select vcenter
printf "\n%bVcenter :%b\n\n" "${REVERSE}${GREEN}" "${STD}"
printf "%b1%b : region 1\n" "${GREEN}${BOLD}" "${STD}"
printf "%b2%b : region 2\n" "${GREEN}${BOLD}" "${STD}"
printf "\n%bYour choice :%b " "${GREEN}${BOLD}" "${STD}" ; read choice
case "${choice}" in
  1) region="region_1" ;;
  2) region="region_2" ;;
  *) printf "\n\n%bERROR : Region unknown.%b\n\n" "${RED}" "${STD}" ; exit 1 ;;
esac

#--- Confirm reboot
printf "\n%bReboot all vms on \"${region}\" vsphere vcenters (y/[n]) ? :%b " "${REVERSE}${GREEN}" "${STD}"
read choice ; printf "\n"
if [ "${choice}" != "y" ] ; then
  exit
fi

#--- Reboot vms on selected vcenter
BEGIN_TS=$(date +%s)
getVmsInfo "${region}"
END_TS=$(date +%s)
duration=$(date -d@$(expr ${END_TS} - ${BEGIN_TS}) -u +%H:%M:%S)
printf "\n%bTotal vms reboot duration on \"${region}\" : ${duration}%b\n\n" "${REVERSE}${YELLOW}" "${STD}"