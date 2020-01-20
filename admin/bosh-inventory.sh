#!/bin/bash
#===========================================================================
# Get tenant instances footprint (without errand instances)
#===========================================================================

#--- Script parameters
INSTANCES_FILE="instances.txt"
BOSH_DIRECTORS="micro master ops coab kubo"

export BOSH_CLIENT="admin"
export BOSH_CA_CERT=~/bosh/secrets/shared/certs/internal_paas-ca/server-ca.crt

export CREDHUB_SERVER="https://credhub.internal.paas:8844"
export CREDHUB_CLIENT="director_to_credhub"
export CREDHUB_SECRET=$(bosh int ~/bosh/secrets/shared/secrets.yml --path /secrets/bosh_credhub_secrets)
export CREDHUB_CA_CERT="${BOSH_CA_CERT}"

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

#--- Log to credhub
credhub api > /dev/null 2>&1
credhub login > /dev/null 2>&1
if [ $? = 1 ] ; then
  printf "\n%bERROR: Log to credhub failed.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
fi

#--- Collect bosh informations
rm -f ${INSTANCES_FILE} > /dev/null 2>&1

for bosh_director in ${BOSH_DIRECTORS} ; do
  case "${bosh_director}" in
    "micro") export BOSH_ENVIRONMENT="192.168.10.10" ; PASSWORD="/secrets/bosh_admin_password" ;;
    "master") export BOSH_ENVIRONMENT="192.168.116.158" ; PASSWORD="/micro-bosh/bosh-master/admin_password" ;;
    "ops") export BOSH_ENVIRONMENT="192.168.99.152" ; PASSWORD="/bosh-master/bosh-ops/admin_password" ;;
    "coab") export BOSH_ENVIRONMENT="192.168.99.155" ; PASSWORD="/bosh-master/bosh-coab/admin_password" ;;
    "kubo") export BOSH_ENVIRONMENT="192.168.99.154" ; PASSWORD="/bosh-master/bosh-kubo/admin_password" ;;
  esac

  flag=$(credhub f | grep "${PASSWORD}")
  if [ "${flag}" != "" ] ; then
    export BOSH_CLIENT_SECRET="$(credhub g -n ${PASSWORD} | grep 'value:' | awk '{print $2}')"
  fi

  bosh alias-env ${bosh_director} > /dev/null 2>&1
  bosh logout > /dev/null 2>&1
  bosh -n log-in > /dev/null 2>&1
  if [ $? = 1 ] ; then
    printf "\n%bERROR: Log to \"${bosh_director}\" director failed.%b\n\n" "${REVERSE}${RED}" "${STD}"
  else
    deployments=$(bosh deployments --json | jq '.Tables[].Rows[].name' | sed -e "s+\"++g")
    printf "\n\n%bCollect \"%s\" bosh director instances details...%b" "${REVERSE}${YELLOW}" "${bosh_director}" "${STD}"
    for deployment in ${deployments} ; do
      #--- Collect active instances properties
      result=$(bosh -d ${deployment} is --details --json)
      flag=$(echo "${result}" | grep "unresponsive agent")
      if [ "${flag}" != "" ] ; then
        printf "\n%b- \"%s\" unavailable%b" "${RED}" "${deployment}" "${STD}"
      else
        #--- Collect cpu, ram and disk properties for each instances 
        result=$(echo "${result}" | jq -r '.Tables[].Rows[]|select(.process_state | length > 0)|.instance + "|" + .vm_cid + "|" + .ips + "|" + .vm_type' | sed -zE "s/([0-9].)\n([0-9].)/\1,\2/g")
        if [ "${result}" = "" ] ; then
          printf "\n%b- \"%s\" inactive%b" "${RED}" "${deployment}" "${STD}"
        else
          printf "\n%b- \"%s\"%b" "${YELLOW}" "${deployment}" "${STD}"
          for instance in $(echo "${result}" | awk -F "|" '{print $1}') ; do
            instance_properties=$(echo "${result}" | grep "${instance}")
            instance_usage=$(bosh -d ${deployment} ssh ${instance} -c "mpstat | grep ' all' | sed -e 's+.* ++' | tr '\n' '|' ; free -m | awk '/^Mem:/{printf(\"%d|%d|\",\$2/1024+0.5,\$4/1024+0.5)}' ; df -m | awk '{if(\$6 == \"/\"){root=\$2/1024+0.5} ; if(\$6 ~ \"/var/vcap/data\"){data+=\$2/1024+0.5} ; if(\$6 ~ \"/var/vcap/store\"){store+=\$2/1024+0.5}} ; END{printf(\"%d|%d|%d\",root,data,store)}'" | grep ": stdout" | sed -e 's+.*: stdout | ++' | sed -e 's+Connection.*++')
            echo "${bosh_director}|${deployment}|${instance_properties}|${instance_usage}" >> ${INSTANCES_FILE}
          done
        fi
      fi
    done
  fi
done

printf "\n\n%bCollect ended.%b\n\n" "${REVERSE}${GREEN}" "${STD}"