#!/bin/bash
#================================================================================
# Check errors on bosh provisionned vms (duplicate ips, no ips, orphaned vms...)
#================================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

if [ "${IAAS_TYPE}" != "vsphere" ] ; then
  printf "\n\n%bERROR : this script can be used only on \"vsphere\" iaas.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Check vm errors
checkVms() {
  REGION="$1"
  printf "\n%bCheck vms on \"${REGION}\" (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"
  VM_INVENTORY_FILE="/tmp/vms_inventory_${REGION}.tmp"
  VM_ORPHANED_FILE="/tmp/vms_orphaned_${REGION}.err"
  VM_NO_IP_FILE="/tmp/vms_no_ip_${REGION}.err"
  VM_DUPLICATE_IP_FILE="/tmp/vms_duplicate_ip_${REGION}.err"
  > ${VM_INVENTORY_FILE}
  > ${VM_ORPHANED_FILE}
  > ${VM_NO_IP_FILE}
  > ${VM_DUPLICATE_IP_FILE}

  #--- Get vm path name list (filtering to get only resource-pool vms)
  logToGovc "${REGION}"
  VMS_NAME="$(govc find / -type m | grep "/${GOVC_DATACENTER}/vm/${GOVC_VMS_FOLDER}/" | sed -e "s+.*/++g" | grep "^vm-")"

  for vm_name in ${VMS_NAME} ; do
    #--- Get vms properties
    vm_info="$(govc vm.info -json ${vm_name} | jq -r '.VirtualMachines[]')"

    #--- Get bosh properties
    properties="$(echo "${vm_info}" | jq -r '.Value')"
    if [ "${properties}" = "null" ] ; then
      bosh_props=""
      echo "- ${vm_name}" >> ${VM_ORPHANED_FILE}
    else
      tags="$(echo "${vm_info}" | jq -r '.AvailableField[]')"
      key="$(echo "${tags}" | jq -r '.|select(.Name == "director")|.Key')"
      director="$(echo "${properties}" | jq -r --arg KEY "${key}" '.[]|select(.Key|tostring == $KEY)|.Value')"
      key="$(echo "${tags}" | jq -r '.|select(.Name == "deployment")|.Key')"
      deployment="$(echo "${properties}" | jq -r --arg KEY "${key}" '.[]|select(.Key|tostring == $KEY)|.Value')"
      key="$(echo "${tags}" | jq -r '.|select(.Name == "name")|.Key')"
      instance="$(echo "${properties}" | jq -r --arg KEY "${key}" '.[]|select(.Key|tostring == $KEY)|.Value')"
      key="$(echo "${tags}" | jq -r '.|select(.Name == "created_at")|.Key')"
      created="$(echo "${properties}" | jq -r --arg KEY "${key}" '.[]|select(.Key|tostring == $KEY)|.Value')"
      bosh_props=" (${director}/${deployment} ${instance} ${created})"
    fi

    #--- Check if network device has be provisionned
    vm_ip="$(echo "${vm_info}" | jq -r '.Guest.IpAddress')"
    if [ "${vm_ip}" = "" ] ; then
      echo "- ${vm_name}" >> ${VM_NO_IP_FILE}
    else
      netSize="$(echo "${vm_info}" | jq -r '.Guest.Net|length')"
      if [ "${netSize}" = "0" ] ; then
        vm_props="${vm_ip} : ${vm_name}${bosh_props}"
      else
        vm_props="$(echo "${vm_info}" | jq -r --arg BOSH_PROPS "${bosh_props}" '.|.Guest.Net[].IpAddress[] + " : " + .Config.Name + $BOSH_PROPS')"
      fi
      echo "${vm_props}" >> ${VM_INVENTORY_FILE}
    fi
  done

  #--- Extract multi-ips vms (except k8s cluster ips)
  grep -v "^10\.42\." ${VM_INVENTORY_FILE} | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | awk '{
    if($1 == PREV_IP) {printf("- %s\n", PRV_CONTENT) ; flag=1}
    else {if(flag == 1) {printf("- %s\n", PRV_CONTENT) ; flag=0}}
    PREV_IP=$1 ; PRV_CONTENT=$0
  } END {if(flag == 1){printf("- %s\n", PRV_CONTENT)}}' > ${VM_DUPLICATE_IP_FILE}
  rm -f ${VM_INVENTORY_FILE} > /dev/null 2>&1

  #--- Show results
  if [ -s ${VM_ORPHANED_FILE} ] ; then
    printf "\n%bVms orphaned on \"${REGION}\"...%b\n" "${REVERSE}${RED}" "${STD}"
    cat ${VM_ORPHANED_FILE}
  else
    rm -f ${VM_ORPHANED_FILE} > /dev/null 2>&1
  fi

  if [ -s ${VM_NO_IP_FILE} ] ; then
    printf "\n%bVms with no ip on \"${REGION}\"...%b\n" "${REVERSE}${RED}" "${STD}"
    cat ${VM_NO_IP_FILE}
  else
    rm -f ${VM_NO_IP_FILE} > /dev/null 2>&1
  fi

  if [ -s ${VM_DUPLICATE_IP_FILE} ] ; then
    printf "\n%bVms with duplicate ips on \"${REGION}\"...%b\n" "${REVERSE}${RED}" "${STD}"
    cat ${VM_DUPLICATE_IP_FILE}
  else
    rm -f ${VM_DUPLICATE_IP_FILE} > /dev/null 2>&1
  fi
}

#--- Check vms on vcenter regions
clear
checkVms "region_1"
checkVms "region_2"

printf "\n%bResult files are available in \"/tmp/vms_xx.err\".%b\n" "${REVERSE}${YELLOW}" "${STD}"