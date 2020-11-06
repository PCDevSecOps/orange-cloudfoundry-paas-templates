#!/bin/bash
#===========================================================================
# Stop/start bosh deployments on tenant except those needed for restart
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- These deployments must not be stopped (needed to restart)
DO_NOT_STOP_DEPLS="cfcr cfcr-persistent-worker credhub-ha dns-recursor docker-bosh-cli intranet-interco-relay internet-proxy jcr nexus openldap ops-routing logsearch logsearch-ops io-bench weave-scope"

#--- These deployments (on master-depls) will be stopped at the end and restart before the others (required by other deployments)
PRE_START_DEPLS="cf"

#--- Don't operate on special deployments that need to stay active (including bosh directors)
NO_ACTION_DEPLS=$(echo "${BOSH_DIRECTORS} ${DO_NOT_STOP_DEPLS} ${PRE_START_DEPLS}" | sed -e "s+ + | +g")

#--- Initialize log file
LOG_DIR="${HOME}/bosh/logs"
LOG_FILE="${LOG_DIR}/$(basename $0)_$1.log"

if [ ! -d ${LOG_DIR} ] ; then
  mkdir -p ${LOG_DIR} > /dev/null 2>&1
fi
> ${LOG_FILE}

operateDeployments() {
  #--- Check if bosh director has been deployed
  OPERATION="$1"
  checkOperation=0 ; nohup_deployments=0
  logToBosh "$2"
  if [ $? != 1 ] ; then
    if [ "${OPERATION}" = "pre-start" ] || [ "${OPERATION}" = "post-stop" ] ; then
      DEPLOYMENTS="${PRE_START_DEPLS}"
    else
      DEPLOYMENTS="$(bosh deployments --json | jq -r '.Tables[].Rows[].name' | sed -e "s+^+ +g" | sed -e "s+$+ +g" | grep -vE " ${NO_ACTION_DEPLS} ")"
    fi

    if [ "${DEPLOYMENTS}" != "" ] ; then
      for BOSH_DEPLOYMENT in ${DEPLOYMENTS} ; do
        #--- Check if deployment contains multiple mysql node (when master node is not started first, start cluster deployment failed)
        export BOSH_DEPLOYMENT
        bosh_vms="$(bosh vms)"
        nb_mysql_nodes=$(echo "${bosh_vms}" | grep -c "^mysql/")
        if [ ${nb_mysql_nodes} -le 1 ] ; then
          #--- Check if deployment exists with running or failing instances status
          status=$(echo "${bosh_vms}" | grep -E "running|failing")

          case "${OPERATION}" in
            "post-stop") #--- Stop deployment sequentially
              if [ "${status}" != "" ] ; then
                printf "%b- $(date) : ${OPERATION} \"${BOSH_DEPLOYMENT}\"\n" "${STD}" | tee -a ${LOG_FILE}
                bosh -n stop --hard > /dev/null 2>&1
                checkOperation=1
              fi ;;

            "pre-start") #--- Start deployment sequentially
              if [ "${status}" = "" ] ; then
                printf "%b- $(date) : ${OPERATION} \"${BOSH_DEPLOYMENT}\"\n" "${STD}" | tee -a ${LOG_FILE}
                bosh -n start > /dev/null 2>&1
                checkOperation=1
              fi ;;

            "start") #--- Start all deployment in parallel, but wait the end of start before switching on other bosh director
              if [ "${status}" = "" ] ; then
                printf "%b- $(date) : ${OPERATION} \"${BOSH_DEPLOYMENT}\"\n" "${STD}" | tee -a ${LOG_FILE}
                nohup bosh -n start > /dev/null 2>&1 &
                checkOperation=1 ; nohup_deployments=1
              fi ;;

            "stop") #--- Stop all deployment in parallel, but wait the end of stop before switching on other bosh director
              if [ "${status}" != "" ] ; then
                printf "%b- $(date) : ${OPERATION} \"${BOSH_DEPLOYMENT}\"\n" "${STD}" | tee -a ${LOG_FILE}
                nohup bosh -n stop --hard > /dev/null 2>&1 &
                checkOperation=1 ; nohup_deployments=1
              fi ;;
          esac
        fi
      done

      #--- Wait end of nohup bosh operations before switching to an other director
      if [ ${nohup_deployments} -gt 0 ] ; then
        loop=1
        printf "\n"
        while [ ${loop} = 1 ] ; do
          nb_todo=$(ps -ef | grep "bosh -n ${OPERATION}" | grep -cv "grep")
          printf "\r%b$(date) : stay %b${nb_todo}%b deployments to end...%b" "${REVERSE}${YELLOW}" "${BLINK}" "${STD}${REVERSE}${YELLOW}" "${STD}"
          if [ "${nb_todo}" = "0" ] ; then
            printf "\r                                                                        " ; loop=0
          else
            sleep 10
          fi
        done
      fi

      #--- Check if operation has been performed
      if [ ${checkOperation} = 1 ] ; then
        printf "\n%b$(date) : check ${OPERATION} deployments on \"$2-depls\"...%b\n" "${REVERSE}${YELLOW}" "${STD}" | tee -a ${LOG_FILE}
        for BOSH_DEPLOYMENT in ${DEPLOYMENTS} ; do
          export BOSH_DEPLOYMENT
          status=$(bosh vms | grep -E "running|failing")

          case "${OPERATION}" in
            "post-stop")
              if [ "${status}" != "" ] ; then
                printf "%b- %-40s %bnot stopped%b\n" "${STD}" "${BOSH_DEPLOYMENT}" "${RED}" "${STD}" | tee -a ${LOG_FILE}
              else
                printf "%b- %-40s %bstopped%b\n" "${STD}" "${BOSH_DEPLOYMENT}" "${GREEN}" "${STD}" | tee -a ${LOG_FILE}
              fi ;;

            "pre-start")
              if [ "${status}" = "" ] ; then
                printf "%b- %-40s %bnot started%b\n" "${STD}" "${BOSH_DEPLOYMENT}" "${RED}" "${STD}" | tee -a ${LOG_FILE}
              else
                printf "%b- %-40s %bstarted%b\n" "${STD}" "${BOSH_DEPLOYMENT}" "${GREEN}" "${STD}" | tee -a ${LOG_FILE}
              fi ;;

            "start")
              if [ "${status}" = "" ] ; then
                printf "%b- %-40s %bnot started%b\n" "${STD}" "${BOSH_DEPLOYMENT}" "${RED}" "${STD}" | tee -a ${LOG_FILE}
              else
                printf "%b- %-40s %bstarted%b\n" "${STD}" "${BOSH_DEPLOYMENT}" "${GREEN}" "${STD}" | tee -a ${LOG_FILE}
              fi ;;

            "stop")
              if [ "${status}" != "" ] ; then
                printf "%b- %-40s %bnot stopped%b\n" "${STD}" "${BOSH_DEPLOYMENT}" "${RED}" "${STD}" | tee -a ${LOG_FILE}
              else
                printf "%b- %-40s %bstopped%b\n" "${STD}" "${BOSH_DEPLOYMENT}" "${GREEN}" "${STD}" | tee -a ${LOG_FILE}
              fi ;;
          esac
        done
      fi
    fi
  fi
}

stopDeployments() {
  #--- Stop deployments on each bosh director (begining by the end of bosh tree dependencies)
  REVERSE_BOSH_DIRECTORS=$(echo "${BOSH_DIRECTORS}" | awk '{nb=split($0,s);for (i = nb;i >= 0;--i) printf("%s ", s[i])}')
  for director in ${REVERSE_BOSH_DIRECTORS} ; do
    operateDeployments "stop" "${director}"
  done

  #--- Post-stop (deployments needed for ops routing access)
  operateDeployments "post-stop" "master"
}

startDeployments() {
  #--- Pre-start (deployments needed for ops routing access)
  operateDeployments "pre-start" "master"

  #--- Start deployments on each bosh director
  for director in ${BOSH_DIRECTORS} ; do
    operateDeployments "start" "${director}"
  done
}

#---- Check if bosh start/stop in progress
check_operation=$(ps -ef | grep -E "bosh -n start|bosh -n stop" | grep -v "grep")
if [ "${check_operation}" != "" ] ; then
  printf "\n%bERROR: bosh start/stop already in progress.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
fi

#--- Log to credhub
if [ ! -s "${BOSH_CA_CERT}" ] ; then
  printf "\n%bERROR: CA cert file \"${BOSH_CA_CERT}\" unknown.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
fi

logToCredhub

#--- Identify operation
case "$1" in
  "stop") stopDeployments ;;
  "start") startDeployments ;;
  *) printf "\n%bERROR: Operation unknown (start/stop).%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1 ;;
esac

printf "\n"