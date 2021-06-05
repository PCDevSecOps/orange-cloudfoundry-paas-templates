#!/bin/bash
#===========================================================================
# Get tenant instances footprint (without errand instances)
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Script parameters
INSTANCES_FILE="/tmp/instances.txt"
rm -f ${INSTANCES_FILE} > /dev/null 2>&1

#--- Collect bosh informations
clear
for bosh_director in ${BOSH_DIRECTORS} ; do
  logToBosh "${bosh_director}"
  if [ $? != 1 ] ; then
    printf "\n\n%bCollect \"%s\" bosh director instances details...%b" "${REVERSE}${YELLOW}" "${bosh_director}" "${STD}"
    deployments=$(bosh deployments --json | jq -r '.Tables[].Rows[].name' | sed -e "s+\"++g")
    for deployment in ${deployments} ; do
      #--- Collect active instances properties
      result=$(bosh -d ${deployment} is --details --json)
      flag=$(echo "${result}" | grep "unresponsive agent")
      if [ "${flag}" != "" ] ; then
        printf "\n%b- \"%s\" unavailable%b" "${RED}" "${deployment}" "${STD}"
      else
        #--- Collect cpu, ram and disk properties for each instances
        instances_properties=$(echo "${result}" | jq -r '.Tables[].Rows[]|select(.process_state | length > 0)|.instance + "|" + .vm_cid + "|" + .disk_cids + "|" + .ips + "|" + .vm_type' | sed -zE "s/([0-9].)\n([0-9].)/\1,\2/g")
        if [ "${instances_properties}" = "" ] ; then
          printf "\n%b- \"%s\" inactive%b" "${YELLOW}" "${deployment}" "${STD}"
        else
          printf "\n%b- \"%s\"" "${STD}" "${deployment}"
          instance_names="$(echo "${instances_properties}" | awk -F "|" '{print $1}')"
          for instance in ${instance_names} ; do
            instance_properties=$(echo "${instances_properties}" | grep "${instance}")
            instance_usage=$(bosh -d ${deployment} ssh ${instance} -c "free -m | awk '/^Mem:/{printf(\"%d|%d|\",\$2/1024+0.5,\$4/1024+0.5)}' ; df -m | awk '{if(\$6 == \"/\"){root=\$2/1024+0.5} ; if(\$6 ~ \"/var/vcap/data\"){data+=\$2/1024+0.5} ; if(\$6 ~ \"/var/vcap/store\"){store+=\$2/1024+0.5}} ; END{printf(\"%d|%d|%d\",root,data,store)}'" | grep ": stdout" | sed -e 's+.*: stdout | ++' | sed -e 's+Connection.*++')
            echo "${bosh_director}|${deployment}|${instance_properties}|${instance_usage}" >> ${INSTANCES_FILE}
          done
        fi
      fi
    done
  fi
done

printf "\n\n%bCollect ended.\nResult available in \"${INSTANCES_FILE}\"%b\n\n" "${REVERSE}${GREEN}" "${STD}"