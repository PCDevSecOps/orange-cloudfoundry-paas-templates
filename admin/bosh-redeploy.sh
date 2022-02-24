#!/bin/bash
#===========================================================================
# Redeploy bosh deployments which uses MTLS certs from a selected deployment
# This script is used in the "3 steps rotation" process
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Max bosh redeploy batchs excuted in parallel
export MAX_BATCH=5

#--- Redeploy bosh deployment
startRedeploy() {
  director_name="$1"
  director_depls="$2"
  deployment="$3"
  deployment_manifest="${LOG_DIR}/${director_depls}_${deployment}.yml"
  deployment_log="${LOG_DIR}/${director_depls}_${deployment}.log"
  is_active="$(echo "${ACTIVE_BOSH_DEPLOYMENTS}" | grep "${deployment}")"

  if [ "${is_active}" != "" ] ; then
    #--- Generate current manifest
    bosh -d ${deployment} manifest > ${deployment_manifest} 2> /dev/null
    if [ $? != 0 ] ; then
      printf "\n%b- $(date +%H:%M:%S) => start \"/${director_depls}/${deployment}\"... %bmanifest not generated)%b" "${STD}" "${RED}" "${STD}"
      printf "ERROR: \"/${director_depls}/${deployment}\" manifest not generated\n" > ${deployment_log}
    else
      #--- Check if deployment has already been processed (bosh tag in manifest)
      check_processed="$(grep "certs_rotation_step: ${CURRENT_STEP}" ${deployment_manifest})"
      if [ "${check_processed}" != "" ] ; then
        printf "\n%b- $(date +%H:%M:%S) => start \"/${director_depls}/${deployment}\"... %balready deployed%b" "${STD}" "${YELLOW}" "${STD}"
      else
        #--- Set bosh tag in deployment manifest to mark it for inventory
        flag_exists="$(grep "certs_rotation_step:" ${deployment_manifest})"
        if [ "${flag_exists}" = "" ] ; then
          printf "tags:\n  certs_rotation_step: ${CURRENT_STEP}\n" >> ${deployment_manifest}
        else
          sed -i "s+certs_rotation_step: .*+certs_rotation_step: ${CURRENT_STEP}+" ${deployment_manifest}
        fi

        #--- Start a new redeployment if not reach MAX_BATCH (to control load on bosh director)
        loop=1
        while [ ${loop} = 1 ] ; do
          nb_batch_in_process=$(ps -ef | grep -c "bosh -d .* -n deploy --recreate ${LOG_DIR}")
          if [ ${nb_batch_in_process} -lt ${MAX_BATCH} ] ; then
            loop=0
          else
            sleep 30
          fi
        done

        #--- Redeploy with instance recreation
        printf "\n%b- $(date +%H:%M:%S) => start \"/${director_depls}/${deployment}\"..." "${STD}"
        printf "=> redeploy \"/${director_depls}/${deployment}\"...\n" > ${deployment_log}
        nohup bosh -d ${deployment} -n deploy --recreate ${deployment_manifest} >> ${deployment_log} 2>&1 &
      fi
    fi
  fi
}

#--- Regenerate manifest deployment and check if certs_rotation_step tag exists
checkDeployment() {
  deployment="$1"
  is_active="$(echo "${ACTIVE_BOSH_DEPLOYMENTS}" | grep "${deployment}")"

  if [ "${is_active}" != "" ] ; then
    #--- Regenerate deployment manifest and check rotation step
    deployment_manifest="${LOG_DIR}/${BOSH_DEPLS_NAME}_${deployment}.yml"
    bosh -d ${deployment} manifest > ${deployment_manifest} 2> /dev/null
    if [ $? != 0 ] ; then
      printf "\n%b- redeploy \"/${BOSH_DEPLS_NAME}/${deployment}\" %bfailed (manifest not generated)%b" "${STD}" "${RED}" "${STD}" ; FLAG_ERROR=1
    else
      #--- Check logs from deployment
      check_logs="$(grep 'Expected task .* to succeed but state is' ${LOG_DIR}/*_${deployment}.log 2> /dev/null)"
      if [ "${check_logs}" != "" ] ; then
        printf "\n%b- redeploy \"/${BOSH_DEPLS_NAME}/${deployment}\" %bfailed%b" "${STD}" "${RED}" "${STD}" ; FLAG_ERROR=1
      else
        #--- Check if deployment has already been processed (bosh tag in manifest)
        check_processed="$(grep "certs_rotation_step: ${CURRENT_STEP}" ${deployment_manifest})"
        if [ "${check_processed}" = "" ] ; then
          printf "\n%b- redeploy \"/${BOSH_DEPLS_NAME}/${deployment}\" %bfailed%b" "${STD}" "${RED}" "${STD}" ; FLAG_ERROR=1
        else
          printf "\n%b- redeploy \"/${BOSH_DEPLS_NAME}/${deployment}\" %bdone%b" "${STD}" "${GREEN}" "${STD}"
        fi
      fi
    fi
  fi
}

#--- Check current step
export CURRENT_STEP="$1"
case "${CURRENT_STEP}" in
  1) next="ok" ;;
  2) next="ok" ;;
  3) next="ok" ;;
  *) printf "\n%bERROR: Unknown step \"${CURRENT_STEP}\".%b\n\n" "${RED}" "${STD}" ; exit 1 ;;
esac

#--- Check selected bosh deployment
if [ "${BOSH_TARGET}" = "" ] || [ "${BOSH_DEPLOYMENT}" = "" ] ; then
  printf "\n%bERROR: You have to log to bosh director first and select main deployment for certs rotation.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Identify linked deployments you have to redeploy after each cert rotation step
next="ok"
DEPLOYMENTS_TO_DEPLOY=""
MAIN_BOSH_TARGET="${BOSH_TARGET}"
selectBoshDirector "${BOSH_TARGET}"

case "${BOSH_DEPLOYMENT}" in
  #--- Bosh director coab
  "bosh-coab") DEPLOYMENTS_TO_DEPLOY="/coab-depls/all
    /master-depls/prometheus-exporter-coab" ;;

  #--- Bosh deployments with linked deployments which use certs
  "cf") DEPLOYMENTS_TO_DEPLOY="/master-depls/isolation-segment-internal
    /master-depls/isolation-segment-internet
    /master-depls/isolation-segment-intranet-1
    /master-depls/isolation-segment-intranet-2" ;;

  #--- Others deployments not allowed to use 3 steps rotation
  *) next="ko" ;;
esac

#--- Check non authorized deployments
if [ "${next}" = "ko" ] ; then
  printf "\n%bERROR: Cannot use this script for \"${BOSH_DEPLOYMENT}\" deployment.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Add main deployment at first position
DEPLOYMENTS_TO_DEPLOY="/${BOSH_DEPLS_NAME}/${BOSH_DEPLOYMENT}
${DEPLOYMENTS_TO_DEPLOY}"
DEPLOYMENTS_TO_DEPLOY="$(echo "${DEPLOYMENTS_TO_DEPLOY}" | sed -e "s+ *++g")"

#--- Confirm redeployments
printf "\n%bYou are going to redeploy following deployments for certs rotation step ${CURRENT_STEP}%b\n${DEPLOYMENTS_TO_DEPLOY}\n" "${REVERSE}${GREEN}" "${STD}"
printf "\n%bContinue (y/[n]) ? :%b " "${REVERSE}${GREEN}" "${STD}" ; read choice
if [ "${choice}" != "y" ] ; then
  printf "\n" ; exit 1
fi

#--- Create temporary directory for logs and manifests, then set default log for bosh cli operations
export LOG_DIR="/data/shared/bosh_redeploy"
rm -fr ${LOG_DIR} > /dev/null 2>&1
createDir "${LOG_DIR}"
unset BOSH_LOG_LEVEL

#--- Redeploy deployments in each bosh directors
printf "\n%bRedeploy \"/${MAIN_BOSH_TARGET}/${BOSH_DEPLOYMENT}\" and linked deployments%b" "${REVERSE}${YELLOW}" "${STD}"
BEGIN_TS=$(date +%s)
OLD_BOSH_DIRECTOR_NAME=""
for deployment_to_process in ${DEPLOYMENTS_TO_DEPLOY} ; do
  bosh_director="$(echo "${deployment_to_process}" | awk -F "/" '{print $2}' | sed -e "s+-depls++g")"
  bosh_deployment="$(echo "${deployment_to_process}" | awk -F "/" '{print $3}')"
  selectBoshDirector "${bosh_director}"

  #--- Check if deployment is a bosh director and that no tasks processing for this bosh director (except prometheus metrics collection)
  is_director="false"
  case "${deployment_to_process}" in
    "bosh-master") is_director="true" ;;
    "bosh-ops") is_director="true" ;;
    "bosh-coab") is_director="true" ;;
    "bosh-remote-r2") is_director="true" ;;
    "bosh-remote-r3") is_director="true" ;;
  esac

  if [ "${is_director}" = "true" ] ; then
    active_tasks=$(bosh tasks | grep -v "retrieve vm-stats" 2>/dev/null)
    if [ "${active_tasks}" != "" ] ; then
      printf "\n%bERROR: bosh director \"${deployment_to_process}\" must not have any active tasks processing:%b\n${active_tasks}\n\n" "${RED}" "${STD}" ; exit 1
    fi
  fi

  #--- Check active bosh deployment (once by bosh director to optimize process)
  if [ "${BOSH_DIRECTOR_NAME}" != "${OLD_BOSH_DIRECTOR_NAME}" ] ; then
    ACTIVE_BOSH_DEPLOYMENTS="$(bosh deployments --json | jq -r '.Tables[].Rows[].name')"
    OLD_BOSH_DIRECTOR_NAME="${BOSH_DIRECTOR_NAME}"
  fi

  #--- Wait main deployment (cf, bosh director) to be deployed before redeploying linked deployments
  loop=1
  while [ ${loop} = 1 ] ; do
    main_deployment=$(ps -ef | grep "bosh -d ${BOSH_DEPLOYMENT} -n deploy --recreate ${LOG_DIR}" | grep -cv "grep")
    if [ ${main_deployment} = 0 ] ; then
      loop=0
    else
      sleep 30
    fi
  done

  if [ "${bosh_deployment}" = "all" ] ; then
    #--- Redeploy all bosh director managed deployments
    for current_deployment in ${ACTIVE_BOSH_DEPLOYMENTS} ; do
      startRedeploy "${BOSH_DIRECTOR_NAME}" "${BOSH_DEPLS_NAME}" "${current_deployment}"
    done
  else
    #--- Redeploy defined bosh deployment
    startRedeploy "${BOSH_DIRECTOR_NAME}" "${BOSH_DEPLS_NAME}" "${bosh_deployment}"
  fi
done

#--- Wait end of all managed deployments
loop=1
while [ ${loop} = 1 ] ; do
  nb_batch_in_process=$(ps -ef | grep "bosh -d .* -n deploy --recreate ${LOG_DIR}" | grep -cv "grep")
  if [ ${nb_batch_in_process} = 0 ] ; then
    loop=0
  else
    sleep 30
  fi
done

#--- Check redeploy status
printf "\n\n%bCheck \"/${MAIN_BOSH_TARGET}/${BOSH_DEPLOYMENT}\" and linked deployments status%b" "${REVERSE}${YELLOW}" "${STD}"
FLAG_ERROR=0
OLD_BOSH_DIRECTOR_NAME=""

for deployment_to_process in ${DEPLOYMENTS_TO_DEPLOY} ; do
  bosh_director="$(echo "${deployment_to_process}" | awk -F "/" '{print $2}' | sed -e "s+-depls++g")"
  bosh_deployment="$(echo "${deployment_to_process}" | awk -F "/" '{print $3}')"
  selectBoshDirector "${bosh_director}"

  #--- Check active bosh deployment (once by bosh director to optimize process)
  if [ "${BOSH_DIRECTOR_NAME}" != "${OLD_BOSH_DIRECTOR_NAME}" ] ; then
    ACTIVE_BOSH_DEPLOYMENTS="$(bosh deployments --json | jq -r '.Tables[].Rows[].name' | grep -vE "docker-bosh-cli")"
    OLD_BOSH_DIRECTOR_NAME="${BOSH_DIRECTOR_NAME}"
  fi

  if [ "${bosh_deployment}" = "all" ] ; then
    #--- Check all bosh director managed deployments
    for current_deployment in ${ACTIVE_BOSH_DEPLOYMENTS} ; do
      checkDeployment "${current_deployment}"
    done
  else
    #--- Check defined bosh deployment
    checkDeployment "${bosh_deployment}"
  fi
done

if [ ${FLAG_ERROR} = 0 ] ; then
  printf "\n\n%bAll deployments have been redeployed successfully%b\n" "${GREEN}" "${STD}"
else
  printf "\n\n%bERROR: Some deployments failed to redeploy.\nCheck log files in \"${LOG_DIR}\"%b\n" "${RED}" "${STD}"
fi

END_TS=$(date +%s)
duration=$(date -d@$(expr ${END_TS} - ${BEGIN_TS}) -u +%H:%M:%S)
printf "\n%bRedeploy duration: ${duration}%b\n\n" "${REVERSE}${YELLOW}" "${STD}"