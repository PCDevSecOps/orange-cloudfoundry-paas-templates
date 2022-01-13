#!/bin/bash
#===========================================================================
# Get instances footprint from bosh inventory
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Script parameters
INVENTORY_FILE="/tmp/bosh-inventory.txt"
rm -f ${INVENTORY_FILE} > /dev/null 2>&1

#--- Collect bosh informations
clear
for bosh_director in ${BOSH_DIRECTORS} ; do
  logToBosh "${bosh_director}"
  if [ $? != 1 ] ; then
    printf "\n\n%bCollect \"${bosh_director}\" bosh director instances details...%b" "${REVERSE}${YELLOW}" "${STD}"
    deployments=$(bosh deployments --json | jq -r '.Tables[].Rows[].name' | sed -e "s+\"++g")
    for deployment in ${deployments} ; do
      #--- Collect instances properties
      result="$(bosh -d ${deployment} is --details --json | sed -e "s+\\\n+,+g")"
      instances_properties="$(echo "${result}" | jq -r '.Tables[].Rows[]|select(.ips != "")|.instance + "|" + .process_state + "|" + .ips + "|" + .vm_type + "|" + .vm_cid')"
      if [ "${instances_properties}" = "" ] ; then
        printf "\n- \"${deployment}\" %b=> no active vms%b" "${YELLOW}" "${STD}"
      else
        printf "\n- \"${deployment}\""
        instances_names="$(echo "${instances_properties}" | awk -F "|" '{print $1}')"
        for instance in ${instances_names} ; do
          #--- Check deployment that could not be accessed with "bosh ssh"
          instance_properties="$(echo "${instances_properties}" | grep "${instance}")"
          instance_status="$(echo "${instance_properties}" | awk -F "|" '{print $2}')"
          instance_ips="$(echo "${instance_properties}" | awk -F "|" '{print $3}')"
          instance_flavor="$(echo "${instance_properties}" | awk -F "|" '{print $4}')"
          instance_id="$(echo "${instance_properties}" | awk -F "|" '{print $5}')"

          if [ "${deployment}" = "00-bootstrap" ] || [ "${instance_status}" = "unresponsive agent" ] ; then
            instance_usage=""
          else
            instance_usage=$(bosh -d ${deployment} ssh ${instance} -c "df -m | awk '{if(\$6 == \"/\"){root=\$2/1024+0.5} ; if(\$6 ~ \"/var/vcap/data\"){data+=\$2/1024+0.5} ; if(\$6 ~ \"/var/vcap/store\"){store+=\$2/1024+0.5}} ; END{printf(\"%d|%d|%d\",root,data,store)}'" | grep ": stdout" | sed -e 's+.*: stdout | ++' | sed -e 's+Connection.*++')
          fi
          echo "${instance_id}|${bosh_director}|${deployment}|${instance}|${instance_ips}|${instance_flavor}|${instance_usage}" >> ${INVENTORY_FILE}
        done
      fi
    done
  fi
done

printf "\n\n%bResult available in \"${INVENTORY_FILE}\"%b\n\n" "${REVERSE}${GREEN}" "${STD}"