#!/bin/bash
#===========================================================================
# Delete credhub obsolete properties and old cert versions
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Collect active bosh deployments for each root director
clear
logToCredhub
printf "\n%bCollect bosh active deployment names (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"
filter="" ; active_bosh_deployments="" ; flag_bosh_director_active=0

for bosh_director in ${BOSH_DIRECTORS} ; do
  logToBosh "${bosh_director}"
  if [ $? != 1 ] ; then
    flag_bosh_director_active=1
    deployments=$(bosh deployments --json | jq -r '.Tables[].Rows[].name' | sed -e "s+^+/${bosh_director}/+g" | sed -e "s+$+/+g")
    active_bosh_deployments="${deployments} ${active_bosh_deployments}"
    filter="/${bosh_director}/|${filter}"
  fi
done

if [ ${flag_bosh_director_active} = 0 ] ; then
  printf "\n%bERROR: Unable to log to bosh directors.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

filter="$(echo "${filter}" | sed -e "s+|$++")"
CREDHUB_PROPERTIES="$(credhub f -j | jq -r '.credentials[].name' | grep -v "/certs/micro-bosh/" | grep -E "${filter}" | LC_ALL=C sort)"

#--- Delete obsolete credhub properties
printf "\n%bCheck obsolete credhub properties to delete...%b\n" "${REVERSE}${YELLOW}" "${STD}"
credhub_properties_to_delete=""
for propertie in ${CREDHUB_PROPERTIES} ; do
  namespace=$(echo "${propertie}" | awk -F "/" '{print "/" $2 "/" $3 "/"}')
  flag=$(echo "${active_bosh_deployments}" | grep "${namespace}")
  if [ "${flag}" = "" ] ; then
    printf "\n- \"${propertie}\""
    credhub_properties_to_delete="${propertie} ${credhub_properties_to_delete}"
  fi
done

if [ "${credhub_properties_to_delete}" != "" ] ; then
  #--- Confirm certs deletion
  printf "\n\n%bDelete credhub certs (y/[n]) ? :%b " "${REVERSE}${GREEN}" "${STD}" ; read choice
  printf "\n"
  if [ "${choice}" != "y" ] ; then
    exit 1
  fi

  #--- Delete obsolete credhub properties
  printf "\n%bDelete obsolete credhub properties...%b\n" "${REVERSE}${YELLOW}" "${STD}"
  for propertie in ${credhub_properties_to_delete} ; do
    printf "\n- Delete obsolete credhub property \"${propertie}\""
    credhub d -n ${propertie} > /dev/null 2>&1
    if [ $? != 0 ] ; then
      printf "\n%bERROR: Delete credhub property \"${propertie}\" failed.%b\n\n" "${RED}" "${STD}" ; exit 1
    fi
  done
fi

#--- Delete obsolete credhub certs versions
printf "\n\n%bCollect credhub certs informations (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"
executeCredhubCurl "GET" "certificates"
CERTS_PROPERTIES="${CREDHUB_API_RESULT}"
CERT_NAMES="$(echo "${CERTS_PROPERTIES}" | jq -r '.certificates[].name' | grep -E "${filter}" | uniq | LC_ALL=C sort)"

for cert_name in ${CERT_NAMES} ; do
  versions="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${cert_name}" '.certificates[]|select(.name == $NAME)|.versions[].id')"
  nb_versions="$(echo "${versions}" | wc -l)"
  if [ ${nb_versions} -gt 1 ] ; then
    cert_id="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${cert_name}" '.certificates[]|select(.name == $NAME)|.id')"
    executeCredhubCurl "GET" "certificates/${cert_id}/versions?current=true"
    current_version_id="$(echo "${CREDHUB_API_RESULT}" | jq -r '.[]|select(.transitional == false)|.id')"
    obsolete_cert_versions="$(echo "${versions}" | grep -v "${current_version_id}")"
    if [ "${obsolete_cert_versions}" != "" ] ; then
      NB=$(expr ${nb_versions} - 1)
      printf "\n- Delete ${NB} obsolete certs for ${cert_name}\" certificate..."
      for version_id in ${obsolete_cert_versions} ; do
        executeCredhubCurl "DELETE" "certificates/${cert_id}/versions/${version_id}"
        printf "\n- Delete \"${obsolete_cert_versions}\"..."
      done
    fi
  fi
done

printf "\n"