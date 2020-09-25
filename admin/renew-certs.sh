#!/bin/bash
#===========================================================================
# Renew credhub certs in 3 steps (with intermediate redeployments)
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Clean obsolete certs versions in credhub
cleanObsoleteCertVersions() {
  versions="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "$1" '.certificates[]|select(.name == $NAME)|.versions[].id')"
  nb_versions="$(echo "${versions}" | wc -l)"
  if [ ${nb_versions} -gt 1 ] ; then
    executeCredhubCurl "GET" "certificates/$2/versions?current=true"
    current_version_id="$(echo "${CREDHUB_API_RESULT}" | jq -r '.[]|select(.transitional == false)|.id')"
    obsolete_cert_versions="$(echo "${versions}" | grep -v "${current_version_id}")"
    if [ "${obsolete_cert_versions}" != "" ] ; then
      nb_obsolete_cert_versions=$(expr ${nb_versions} - 1)
      printf "%b- Delete ${nb_obsolete_cert_versions} obsolete certs for \"$1\" certificate...\n" "${STD}"
      for version_id in ${obsolete_cert_versions} ; do
        executeCredhubCurl "DELETE" "certificates/$2/versions/${version_id}"
      done
    fi
  fi
}

#--- Step 1: Renew CA that will expire in credhub with transitional flag (not be used for signing yet)
#    Need to redeploy all bosh-director deployments to propagate new CA at the end of the step
renewCACerts() {
  #--- Select a bosh director
  clear
  selectBoshDirector

  #--- Get deployments with CA certs wich expired until CERT_EXPIRATION_IN_DAYS
  executeCredhubCurl "GET" "data?name-like=/${BOSH_DIRECTOR_NAME}&expires-within-days=${CERT_EXPIRATION_IN_DAYS}"
  EXPIRES_CERT_NAMES="$(echo "${CREDHUB_API_RESULT}" | jq -r '.credentials[].name' | grep "^/${BOSH_DIRECTOR_NAME}")"
  deployments="$(echo "${EXPIRES_CERT_NAMES}" | awk -F "/" '{print $3}' | LC_ALL=C sort | uniq)"
  printf "\n%bSelect a deployment with expiring certs :%b\n%s" "${REVERSE}${GREEN}" "${STD}" "${deployments}"
  printf "\n\n%bYour choice (<Enter> to renew all cert) :%b " "${GREEN}${BOLD}" "${STD}" ; read deployment
  if [ "${deployment}" = "" ] ; then
    filter="${BOSH_DIRECTOR_NAME}"
  else
    flag=$(echo "${deployments}" | grep "${deployment}")
    if [ "${flag}" = "" ] ; then
      printf "\n%bERROR: Unknown deployment \"${deployment}\".%b\n\n" "${RED}" "${STD}" ; exit 1
    fi
    filter="${BOSH_DIRECTOR_NAME}/${deployment}"
    deployments=${deployment}
  fi

  clear
  printf "\n%bCerts rotation step 1 : Renew \"${BOSH_DIRECTOR_NAME}\" CA certs that will expire within ${CERT_EXPIRATION_IN_DAYS} days%b\n" "${REVERSE}${YELLOW}" "${STD}"
  CA_CERT_NAMES="$(echo "${CERTS_PROPERTIES}" | jq -r '.certificates[]|select(.versions[].certificate_authority == true)|.name' | uniq | LC_ALL=C sort | grep "^/${filter}/")"
  for cert_name in ${EXPIRES_CERT_NAMES} ; do
    #--- Check if certificate is CA
    is_ca="$(echo "${CA_CERT_NAMES}" | sed -e "s+^+ +g" | sed -e "s+$+ +g" | grep " ${cert_name} ")"
    if [ "${is_ca}" != "" ] ; then
      cert_id="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${cert_name}" '.certificates[]|select(.name == $NAME)|.id')"
      cleanObsoleteCertVersions "${cert_name}" "${cert_id}"
      printf "%b- Renew \"${cert_name}\"...\n" "${STD}"
      EXPIRES_CA_CERT_NAMES="${EXPIRES_CA_CERT_NAMES}|${cert_name}"
      executeCredhubCurl "POST" "certificates/${cert_id}/regenerate" \"set_as_transitional\":true
    fi
  done

  #--- Store certs rotation informations in credhub (for next steps)
  EXPIRES_CA_CERT_NAMES="$(echo "${EXPIRES_CA_CERT_NAMES}" | sed -e "s+^|++g")"
  if [ "${EXPIRES_CA_CERT_NAMES}" = "" ] ; then
    printf "\n%bNo CA certs to renew in \"${BOSH_DIRECTOR_NAME}\" director.%b\n\n" "${YELLOW}" "${STD}"
  else
    executeCredhubCurl "PUT" "data" \"name\":\"/renew_certs_step\",\"type\":\"value\",\"value\":\"2\"
    executeCredhubCurl "PUT" "data" \"name\":\"/renew_certs_director\",\"type\":\"value\",\"value\":\"${BOSH_DIRECTOR_NAME}\"
    executeCredhubCurl "PUT" "data" \"name\":\"/renew_certs_list\",\"type\":\"value\",\"value\":\"${EXPIRES_CA_CERT_NAMES}\"
    printf "\n%bYou have now to redeploy following deployments in \"${BOSH_DIRECTOR_NAME}\" (to propagate new CA certs).\n${deployments}%b\n\n" "${YELLOW}" "${STD}"
  fi
}

#--- Step 2: Switch transitional flag from the old to the new CA certificate, and renew leaf certificates
#    Need to redeploy all bosh-director deployments to propagate new certificates at the end of the step
renewLeafCerts() {
  printf "\n%bCerts rotation step 2 : Renew \"${BOSH_DIRECTOR_NAME}\" leaf certs%b\n" "${REVERSE}${YELLOW}" "${STD}"
  for cert_name in ${EXPIRES_CA_CERT_NAMES} ; do
    cert_id="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${cert_name}" '.certificates[]|select(.name == $NAME)|.id')"
    if [ "${cert_id}" = "" ] ; then   #--- CA cert has been deleted since
      EXPIRES_CA_CERT_NAMES="$(echo "${EXPIRES_CA_CERT_NAMES} " | sed -e "s+${cert_name} ++g" | sed -e "s+ $++g")"
    else
      #--- Enable new CA certificate (switch transitional flag to old one)
      printf "%b- Renew \"${cert_name}\" leaf certs...\n" "${STD}"
      executeCredhubCurl "GET" "certificates/${cert_id}/versions?current=true"
      current_version_id="$(echo "${CREDHUB_API_RESULT}" | jq -r '.[]|select(.transitional == false)|.id')"
      executeCredhubCurl "PUT" "certificates/${cert_id}/update_transitional_version" \"version\":\"${current_version_id}\"

      #--- Renew leaf certificates with the new CA cert
      executeCredhubCurl "POST" "bulk-regenerate" \"signed_by\":\"${cert_name}\"
    fi
  done

  #--- Update certs rotation step status (delete and set to avoid multiple versions on propertie that makes error when getting)
  if [ "${EXPIRES_CA_CERT_NAMES}" = "" ] ; then
    printf "\n%bNo CA certs to renew in \"${BOSH_DIRECTOR_NAME}\" director.%b\n\n" "${YELLOW}" "${STD}"
    executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/renew_certs_step"
    executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/renew_certs_director"
    executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/renew_certs_list"
  else
    executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/renew_certs_step"
    executeCredhubCurl "PUT" "data" \"name\":\"/renew_certs_step\",\"type\":\"value\",\"value\":\"3\"
    deployments="$(echo "${EXPIRES_CA_CERT_NAMES} " | awk -F "/" '{print $3}' | LC_ALL=C sort | uniq | sed -e "s+^+- +g")"
    printf "\n%bYou have now to redeploy following deployments in \"${BOSH_DIRECTOR_NAME}\" (to propagate new leaf certs).\n${deployments}%b\n\n" "${YELLOW}" "${STD}"
  fi
}

#--- Step 3: Remove old certs versions
removeOldCerts() {
  printf "\n%bCerts rotation step 3 : Remove old \"${BOSH_DIRECTOR_NAME}\" certs%b\n" "${REVERSE}${YELLOW}" "${STD}"
  CERT_NAMES="$(echo "${CERTS_PROPERTIES}" | jq -r '.certificates[].name' | uniq | LC_ALL=C sort | grep "^/${BOSH_DIRECTOR_NAME}")"
  for cert_name in ${CERT_NAMES} ; do
    cert_id="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${cert_name}" '.certificates[]|select(.name == $NAME)|.id')"
    if [ "${cert_id}" = "" ] ; then   #--- CA cert has been deleted since
      CERT_NAMES="$(echo "${CERT_NAMES} " | sed -e "s+${cert_name} ++g" | sed -e "s+ $++g")"
    else
      cleanObsoleteCertVersions "${cert_name}" "${cert_id}"
    fi
  done

  #--- Delete credhub values used for rotation process
  executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/renew_certs_step"
  executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/renew_certs_director"
  executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/renew_certs_list"
  if [ "${CERT_NAMES}" != "" ] ; then
    deployments="$(echo "${EXPIRES_CA_CERT_NAMES} " | awk -F "/" '{print $3}' | LC_ALL=C sort | uniq | sed -e "s+^+- +g")"
    printf "\n%bYou have now to redeploy following deployments in \"${BOSH_DIRECTOR_NAME}\" (to remove old certs).\n${deployments}%b\n\n" "${YELLOW}" "${STD}"
  fi
}

#--- Collect certs in credhub
clear
printf "\n%bCollect credhub certs rotation informations (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"
executeCredhubCurl "GET" "certificates"
CERTS_PROPERTIES="${CREDHUB_API_RESULT}"

#--- Check if some certs are already in rotation process (avoid misleading between steps)
executeCredhubCurl "no_chek_errors" "GET" "data?name=/renew_certs_step"
status="$(echo "${CREDHUB_API_RESULT}" | grep "the credential does not exist")"
if [ "${status}" != "" ] ; then
  CURRENT_STEP=1
else
  #--- Get bosh-director and CA cert list to renew (defined in step 1)
  CURRENT_STEP="$(echo "${CREDHUB_API_RESULT}" | jq -r '.data[].value')"
  executeCredhubCurl "GET" "data?name=/renew_certs_director"
  BOSH_DIRECTOR_NAME="$(echo "${CREDHUB_API_RESULT}" | jq -r '.data[].value')"
  executeCredhubCurl "GET" "data?name=/renew_certs_list"
  EXPIRES_CA_CERT_NAMES="$(echo "${CREDHUB_API_RESULT}" | jq -r '.data[].value' | sed -e "s+|+ +g")"
fi

clear
case "${CURRENT_STEP}" in
  1) renewCACerts ;;
  2) renewLeafCerts ;;
  3) removeOldCerts ;;
  *) printf "\n%bERROR:\nUnknown step \"${CURRENT_STEP}\".%b\n" "${RED}" "${STD}" ; exit 1 ;;
esac