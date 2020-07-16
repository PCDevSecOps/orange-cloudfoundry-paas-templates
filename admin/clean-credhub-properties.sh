#!/bin/bash
#===========================================================================
# Delete credhub obsolete properties and old cert versions
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Script properties
export BOSH_CLIENT="admin"

#--- Collect active bosh deployments for each root director
clear
logToCredhub
printf "\n%bCollect bosh active deployment names (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"
FILTER="" ; ACTIVE_BOSH_DEPLOYMENTS=""
CREDHUB_PROPERTIES="$(credhub f -j | jq -r '.credentials[].name')"

for bosh_director in ${BOSH_DIRECTORS} ; do
  case "${bosh_director}" in
    "micro")  DIRECTOR="micro-bosh" ; export BOSH_ENVIRONMENT="192.168.10.10" ; PASSWORD="/secrets/bosh_admin_password" ;;
    "master") DIRECTOR="bosh-${bosh_director}" ; export BOSH_ENVIRONMENT="192.168.116.158" ; PASSWORD="/micro-bosh/bosh-master/admin_password" ;;
    "ops") DIRECTOR="bosh-${bosh_director}" ; export BOSH_ENVIRONMENT="192.168.99.152" ; PASSWORD="/bosh-master/bosh-ops/admin_password" ;;
    "coab") DIRECTOR="bosh-${bosh_director}" ; export BOSH_ENVIRONMENT="192.168.99.155" ; PASSWORD="/bosh-master/bosh-coab/admin_password" ;;
    "kubo") DIRECTOR="bosh-${bosh_director}" ; export BOSH_ENVIRONMENT="192.168.99.154" ; PASSWORD="/bosh-master/bosh-kubo/admin_password" ;;
    "remote-r2") DIRECTOR="bosh-${bosh_director}" ; export BOSH_ENVIRONMENT="192.168.99.153" ; PASSWORD="/bosh-master/bosh-remote-r2/admin_password" ;;
    "remote-r3") DIRECTOR="bosh-${bosh_director}" ; export BOSH_ENVIRONMENT="192.168.99.156" ; PASSWORD="/bosh-master/bosh-remote-r3/admin_password" ;;
  esac

  flag=$(echo "${CREDHUB_PROPERTIES}" | grep "${PASSWORD}")
  if [ "${flag}" != "" ] ; then
    export BOSH_CLIENT_SECRET="$(credhub g -n ${PASSWORD} | grep 'value:' | awk '{print $2}')"
    bosh alias-env ${bosh_director} > /dev/null 2>&1
    bosh logout > /dev/null 2>&1
    bosh -n log-in > /dev/null 2>&1
    if [ $? = 1 ] ; then
      printf "\n%bERROR: Log to \"${bosh_director}\" director failed.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
    else
      deployments=$(bosh deployments --json | jq -r '.Tables[].Rows[].name' | sed -e "s+^+/${DIRECTOR}/+g" | sed -e "s+$+/+g")
      ACTIVE_BOSH_DEPLOYMENTS="${deployments} ${ACTIVE_BOSH_DEPLOYMENTS}"
    fi
  fi
  FILTER="/${DIRECTOR}/|${FILTER}"
done

FILTER="$(echo "${FILTER}" | sed -e "s+|$++")"
CREDHUB_PROPERTIES="$(echo "${CREDHUB_PROPERTIES}" | grep -E "${FILTER}" | LC_ALL=C sort)"

#--- Delete obsolete credhub properties
printf "\n%bCheck obsolete credhub properties to delete...%b\n" "${REVERSE}${YELLOW}" "${STD}"
CREDHUB_PROPERTIES_TO_DELETE=""
for propertie in ${CREDHUB_PROPERTIES} ; do
  namespace=$(echo "${propertie}" | awk -F "/" '{print "/" $2 "/" $3 "/"}')
  flag=$(echo "${ACTIVE_BOSH_DEPLOYMENTS}" | grep "${namespace}")
  if [ "${flag}" = "" ] ; then
    printf "\n- \"${propertie}\""
    CREDHUB_PROPERTIES_TO_DELETE="${propertie} ${CREDHUB_PROPERTIES_TO_DELETE}"
  fi
done

if [ "${CREDHUB_PROPERTIES_TO_DELETE}" != "" ] ; then
  #--- Confirm certs deletion
  printf "\n%bDelete credhub certs (y/n) ? :%b " "${REVERSE}${GREEN}" "${STD}"
  read choice
  printf "\n"
  if [ "${choice}" != "y" ] ; then
    exit 1
  fi

  #--- Delete obsolete credhub properties
  printf "\n%bDelete obsolete credhub properties...%b\n" "${REVERSE}${YELLOW}" "${STD}"
  for propertie in ${CREDHUB_PROPERTIES_TO_DELETE} ; do
    printf "\n- Delete obsolete credhub propertie \"${propertie}\""
    credhub d -n ${propertie} > /dev/null 2>&1
    if [ $? != 0 ] ; then
      printf "\n%bERROR: Delete credhub propertie \"${propertie}\" failed.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
    fi
  done
fi

#--- Delete obsolete credhub certs versions
printf "\n%bCollect credhub certs (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"
getCertsProperties
CERT_NAMES="$(echo "${CERTS_PROPERTIES}" | jq -r '.certificates[].name' | grep -E "${FILTER}" | uniq | LC_ALL=C sort)"

for cert_name in ${CERT_NAMES} ; do
  VERSIONS="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${cert_name}" '.certificates[]|select(.name == $NAME)|.versions[].id')"
  NB_VERSIONS="$(echo "${VERSIONS}" | wc -l)"
  if [ ${NB_VERSIONS} -gt 1 ] ; then
    CERT_ID="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${cert_name}" '.certificates[]|select(.name == $NAME)|.id')"
    CURRENT_VERSION="$(curl -s ${CREDHUB_API}/certificates/${CERT_ID}/versions?current=true -H "${TOKEN}" -X GET | jq -r '.[]|select(.transitional == false)|.id')"
    if [ $? != 0 ] ; then
      getCredhubToken
      CURRENT_VERSION="$(curl -s ${CREDHUB_API}/certificates/${CERT_ID}/versions?current=true -H "${TOKEN}" -X GET | jq -r '.[]|select(.transitional == false)|.id')"
      if [ $? != 0 ] ; then
        printf "\n%bERROR: Unable to get \"${cert_name}\" current version id.%b\n\n" "${RED}" "${STD}" ; exit 1
      fi
    fi

    OBSOLETE_CERT_VERSIONS="$(echo "${VERSIONS}" | grep -v "${CURRENT_VERSION}")"
    if [ "${OBSOLETE_CERT_VERSIONS}" != "" ] ; then
      NB=$(expr ${NB_VERSIONS} - 1)
      printf "\n- Delete ${NB} obsolete certs for ${cert_name}\" certificate..."
      for version_id in ${OBSOLETE_CERT_VERSIONS} ; do
        curl -s ${CREDHUB_API}/certificates/${CERT_ID}/versions/${version_id} -H "${TOKEN}" -X DELETE > /dev/null 2>&1
        if [ $? != 0 ] ; then
          getCredhubToken
          curl -s ${CREDHUB_API}/certificates/${CERT_ID}/versions/${version_id} -H "${TOKEN}" -X DELETE > /dev/null 2>&1
        fi
      done
    fi
  fi
done

printf "\n"