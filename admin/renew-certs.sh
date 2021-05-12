#!/bin/bash
#===========================================================================
# Renew certs for a selected deployment in 3 steps with credhub (with intermediate redeployments)
# Note : You have to log on bosh director and select a deployment before using this script
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Clean obsolete certs versions in credhub
cleanCerts() {
  for cert_name in $1 ; do
    versions="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${cert_name}" '.certificates[]|select(.name == $NAME)|.versions[].id')"
    nb_versions="$(echo "${versions}" | wc -l)"
    if [ ${nb_versions} -gt 1 ] ; then
      cert_id="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${cert_name}" '.certificates[]|select(.name == $NAME)|.id')"
      executeCredhubCurl "GET" "certificates/${cert_id}/versions?current=true"
      current_version_id="$(echo "${CREDHUB_API_RESULT}" | jq -r '.[]|select(.transitional == false)|.id')"
      obsolete_cert_versions="$(echo "${versions}" | grep -v "${current_version_id}")"
      if [ "${obsolete_cert_versions}" != "" ] ; then
        nb_obsolete_cert_versions=$(expr ${nb_versions} - 1)
        printf "%b- Delete ${nb_obsolete_cert_versions} obsolete \"${cert_name}\" certs...\n" "${STD}"
        for version_id in ${obsolete_cert_versions} ; do
          executeCredhubCurl "DELETE" "certificates/${cert_id}/versions/${version_id}"
        done
      fi
    fi
  done
}

#--- Clean obsolete certs versions in credhub
cleanObsoleteCertVersions() {
  printf "\n%bClean \"$1\" obsolete certs%b\n" "${REVERSE}${YELLOW}" "${STD}"
  #--- Clean deployement ca certs before (else credhub delete generate new certs and it stay 1 obsolete cert at the end)
  ca_cert_names="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "$1" '.certificates[]|select((.name|contains($NAME)) and (.versions[].certificate_authority == true))|.name' | LC_ALL=C sort | uniq)"
  cleanCerts "${ca_cert_names}"

  #--- Clean deployment certs
  cert_names="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "$1" '.certificates[]|select((.name|contains($NAME)) and (.versions[].certificate_authority != true))|.name' | LC_ALL=C sort | uniq)"
  cleanCerts "${cert_names}"
}

#--- Step 1: Renew CA that will expire in credhub with transitional flag (not be used for signing yet)
#    Need to redeploy all bosh-director deployments to propagate new CA at the end of the step
renewCACerts() {
  #--- Check selected bosh deployment
  if [ "${BOSH_TARGET}" = "" ] || [ "${BOSH_DEPLOYMENT}" = "" ] ; then
    printf "\n%bERROR: You have to log to bosh director first and select main deployment for certs rotation.%b\n\n" "${RED}" "${STD}" ; exit 1
  fi

  case "${BOSH_TARGET}" in
    "micro") BOSH_DIRECTOR_NAME="micro-bosh" ; BOSH_DEPLS_NAME="micro-depls" ;;
    "master") BOSH_DIRECTOR_NAME="bosh-master" ; BOSH_DEPLS_NAME="master-depls" ;;
    "ops") BOSH_DIRECTOR_NAME="bosh-ops" ; BOSH_DEPLS_NAME="ops-depls" ;;
    "coab") BOSH_DIRECTOR_NAME="bosh-coab" ; BOSH_DEPLS_NAME="coab-depls" ;;
    "remote-r2") BOSH_DIRECTOR_NAME="bosh-remote-r2" ; BOSH_DEPLS_NAME="remote-r2-depls" ;;
    "remote-r3") BOSH_DIRECTOR_NAME="bosh-remote-r3" ; BOSH_DEPLS_NAME="remote-r3-depls" ;;
    *) printf "\n%bERROR: unknown bosh director \"${BOSH_TARGET}\".%b\n\n" "${RED}" "${STD}" ; exit 1 ;;
  esac

  case "${BOSH_DEPLOYMENT}" in
    "credhub-ha") printf "\n%b\"${DEPLOYMENT}\" deployment could not be rotated with this process.%b\n\n" "${RED}" "${STD}" ; exit 1
  esac

  #--- Confirm cert rotation process start
  printf "\n%bRenew \"/${BOSH_DEPLS_NAME}/${BOSH_DEPLOYMENT}\" certs (y/[n]) ? :%b " "${REVERSE}${GREEN}" "${STD}" ; read choice
  printf "\n"
  if [ "${choice}" != "y" ] ; then
    exit 1
  fi

  #--- Clean obsolete certs versions in credhub for selected deployment
  clear
  DEPLOYMENT_CA_CERT_NAMES=""
  DEPLOYMENT="/${BOSH_DIRECTOR_NAME}/${BOSH_DEPLOYMENT}/"
  deployment_ca_names="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${DEPLOYMENT}" '.certificates[]|select((.name|contains($NAME)) and (.versions[].certificate_authority == true))|.name' | LC_ALL=C sort | uniq)"

  if [ "${deployment_ca_names}" = "" ] ; then
    printf "\n%bERROR: No CA certs for \"${DEPLOYMENT}\" deployment.%b\n\n" "${RED}" "${STD}" ; exit 1
  fi

  #--- Clean obsolete certs versions in credhub for selected deployment
  cleanObsoleteCertVersions "${DEPLOYMENT}"

  #--- Generate new transitional CA certs
  printf "\n%bCerts rotation step 1 : Renew \"${DEPLOYMENT}\" CA certs%b\n" "${REVERSE}${YELLOW}" "${STD}"
  for ca_cert_name in ${deployment_ca_names} ; do
    DEPLOYMENT_CA_CERT_NAMES="${DEPLOYMENT_CA_CERT_NAMES}|${ca_cert_name}"
    printf "%b- Renew \"${ca_cert_name}\"...\n" "${STD}"
    ca_cert_id="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${ca_cert_name}" '.certificates[]|select(.name == $NAME)|.id')"
    executeCredhubCurl "POST" "certificates/${ca_cert_id}/regenerate" \"set_as_transitional\":true
  done

  #--- Store certs rotation informations in credhub (for next step)
  printf "\n%bStore rotation process informations in credhub%b\n" "${REVERSE}${YELLOW}" "${STD}"
  executeCredhubCurl "PUT" "data" \"name\":\"/certs_rotation_step\",\"type\":\"value\",\"value\":\"2\"
  executeCredhubCurl "PUT" "data" \"name\":\"/certs_rotation_deployment\",\"type\":\"value\",\"value\":\"${DEPLOYMENT}\"
  DEPLOYMENT_CA_CERT_NAMES="$(echo "${DEPLOYMENT_CA_CERT_NAMES}" | sed -e "s+^|++g")"
  executeCredhubCurl "PUT" "data" \"name\":\"/certs_rotation_ca_certs\",\"type\":\"value\",\"value\":\"${DEPLOYMENT_CA_CERT_NAMES}\"
  printf "\n%bYou have now to redeploy linked deployments (to propagate new CA certs) with \"bosh-redeploy.sh 1\".%b\n" "${YELLOW}" "${STD}"
}

#--- Step 2: Switch transitional flag from the old to the new CA certificate, and renew leaf certificates
#    Need to redeploy all bosh-director deployments to propagate new certificates at the end of the step
renewLeafCerts() {
  #--- Confirm cert rotation process start
  printf "\n%bCerts rotation step 2 : Renew \"${DEPLOYMENT}\" leaf certs%b\n" "${REVERSE}${YELLOW}" "${STD}"
  printf "\n%bHave you redeploy all linked deployments (to propagate new CA certs)%b\n\n%bContinue (y/[n]) ? :%b " "${BLINK}${REVERSE}${GREEN}" "${STD}" "${REVERSE}${GREEN}" "${STD}" ; read choice
  printf "\n"
  if [ "${choice}" != "y" ] ; then
    exit 1
  fi

  #--- Regenerate leaf certs signed by deployment CA certs
  for ca_cert_name in ${DEPLOYMENT_CA_CERT_NAMES} ; do
    ca_cert_id="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${ca_cert_name}" '.certificates[]|select(.name == $NAME)|.id')"
    if [ "${ca_cert_id}" = "" ] ; then   #--- CA cert has been deleted since
      DEPLOYMENT_CA_CERT_NAMES="$(echo "${DEPLOYMENT_CA_CERT_NAMES} " | sed -e "s+${ca_cert_name} ++g" | sed -e "s+ $++g")"
    else
      #--- Check if transitional ca cert exists
      transitional_version_id="$(echo "${CERTS_PROPERTIES}" | jq -r '.certificates[]|select(.versions[].transitional == true)|.name' | grep "${ca_cert_name}")"
      if [ "${transitional_version_id}" != "" ] ; then   #--- Ca cert has already been switched
        printf "%b- Renew \"${ca_cert_name}\" leaf certs...\n" "${STD}"
        #--- Enable new CA certificate (switch transitional flag to old one)
        executeCredhubCurl "GET" "certificates/${ca_cert_id}/versions?current=true"
        current_version_id="$(echo "${CREDHUB_API_RESULT}" | jq -r '.[]|select(.transitional == false)|.id')"
        executeCredhubCurl "PUT" "certificates/${ca_cert_id}/update_transitional_version" \"version\":\"${current_version_id}\"

        #--- Regenerate leaf certificates with the new CA cert
        executeCredhubCurl "POST" "bulk-regenerate" \"signed_by\":\"${ca_cert_name}\"
      fi
    fi
  done

  #--- Regenerate leaf certs signed by internalCA
  INTERNAL_CA_LEAF_CERTS="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${DEPLOYMENT}" '.certificates[]|select((.name|contains($NAME)) and (.signed_by|contains("/internalCA")) and (.versions[].certificate_authority != true))|.name' | LC_ALL=C sort)"
  if [ "${INTERNAL_CA_LEAF_CERTS}" != "" ] ; then
    printf "%b- Renew \"/internalCA\" leaf certs...\n" "${STD}"
    for leaf_cert in ${INTERNAL_CA_LEAF_CERTS} ; do
      executeCredhubCurl "POST" "regenerate" \"name\":\"${leaf_cert}\"
    done
  fi

  #--- Update certs rotation step status and rotation informations
  #    Delete and set to avoid multiple propertie versions that makes error when getting
  printf "\n%bUpdate rotation process informations in credhub%b\n" "${REVERSE}${YELLOW}" "${STD}"
  if [ "${DEPLOYMENT_CA_CERT_NAMES}" = "" ] ; then
    printf "\n%bNo CA certs to renew for \"${DEPLOYMENT}\" deployment.%b\n\n" "${YELLOW}" "${STD}"
    executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/certs_rotation_step"
    executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/certs_rotation_deployment"
    executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/certs_rotation_ca_certs"
  else
    executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/certs_rotation_step"
    executeCredhubCurl "PUT" "data" \"name\":\"/certs_rotation_step\",\"type\":\"value\",\"value\":\"3\"
    printf "\n%bYou have now to redeploy linked deployments (to propagate new leaf certs) with \"bosh-redeploy.sh 2\".%b\n" "${YELLOW}" "${STD}"
  fi
}

#--- Step 3: Remove old certs versions
removeOldCerts() {
  printf "\n%bCerts rotation step 3 : Remove old \"${DEPLOYMENT}\" certs%b\n" "${REVERSE}${YELLOW}" "${STD}"
  printf "\n%bHave you redeploy all linked deployments (to propagate new leaf certs)%b\n\n%bContinue (y/[n]) ? :%b " "${BLINK}${REVERSE}${GREEN}" "${STD}" "${REVERSE}${GREEN}" "${STD}" ; read choice
  printf "\n"
  if [ "${choice}" != "y" ] ; then
    exit 1
  fi

  #--- Clean obsolete certs versions in credhub
  cleanObsoleteCertVersions "${DEPLOYMENT}"

  #--- Delete rotation process credhub properties
  printf "\n%bDelete rotation process informations in credhub%b\n" "${REVERSE}${YELLOW}" "${STD}"
  executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/certs_rotation_step"
  executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/certs_rotation_deployment"
  executeCredhubCurl "no_chek_errors" "DELETE" "data?name=/certs_rotation_ca_certs"
  printf "\n%bYou could now redeploy linked deployments (to remove old certs) with \"bosh-redeploy.sh 3\".%b\n" "${YELLOW}" "${STD}"
}

#--- Collect certs in credhub
clear
BEGIN_TS=$(date +%s)
printf "\n%bCollect credhub certs informations (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"
executeCredhubCurl "GET" "certificates"
CERTS_PROPERTIES="${CREDHUB_API_RESULT}"

#--- Check if some certs are already in rotation process (avoid misleading between steps)
executeCredhubCurl "no_chek_errors" "GET" "data?name=/certs_rotation_step"
status="$(echo "${CREDHUB_API_RESULT}" | grep "credential does not exist")"
if [ "${status}" != "" ] ; then
  CURRENT_STEP=1
else
  #--- Get bosh-director and CA cert list to renew (defined in step 1)
  CURRENT_STEP="$(echo "${CREDHUB_API_RESULT}" | jq -r '.data[].value')"
  executeCredhubCurl "GET" "data?name=/certs_rotation_deployment"
  DEPLOYMENT="$(echo "${CREDHUB_API_RESULT}" | jq -r '.data[].value')"
  executeCredhubCurl "GET" "data?name=/certs_rotation_ca_certs"
  DEPLOYMENT_CA_CERT_NAMES="$(echo "${CREDHUB_API_RESULT}" | jq -r '.data[].value' | sed -e "s+|+ +g")"
fi

clear
case "${CURRENT_STEP}" in
  1) renewCACerts ;;
  2) renewLeafCerts ;;
  3) removeOldCerts ;;
  *) printf "\n%bERROR:\nUnknown step \"${CURRENT_STEP}\".%b\n" "${RED}" "${STD}" ; exit 1 ;;
esac

END_TS=$(date +%s)
duration=$(date -d@$(expr ${END_TS} - ${BEGIN_TS}) -u +%H:%M:%S)
printf "\n%bCerts rotation duration: ${duration}%b\n\n" "${REVERSE}${YELLOW}" "${STD}"