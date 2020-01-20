#!/bin/bash
#===========================================================================
# Unpause selected concourse pipeline and associated jobs
# Parameters :
# --exclude-jobs, -e : Unpause all jobs except job list (space separated)
# --pipeline, -p     : Target pipelines for unpausing jobs (micro master ops coab kubo)
# --wait, -w         : Wait pause (seconds) before unpausing next jobs
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Check prerequisites
verifyFile "${FLY_CREDENTIALS}"

#--- Check scripts options
usage() {
  printf "\n%bUSAGE:" "${BOLD}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-40s %s" "--exclude-jobs, -e \"job list\"" "Unpause all jobs except job list (space separated)"
  printf "\n  %-40s %s" "--pipeline, -p \"pipeline\"" "Target pipelines (space separated) for unpausing jobs (micro master ops coab kubo)"
  printf "\n  %-40s %s" "--wait, -w \"seconds\"" "Wait pause (seconds) before unpausing next jobs"
  printf "%b\n\n" "${STD}"
  exit 1
}

EXCLUDED_JOBS=""
PIPELINES=""
WAIT_DURATION=""

while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-e"|"--exclude-jobs")
      EXCLUDED_JOBS="$2"
      if [ "${EXCLUDED_JOBS}" = "" ] ; then
        usage
      fi
      shift ; shift ;;
    "-p"|"--pipeline")
        PIPELINES="$2"
        if [ "${PIPELINES}" = "" ] ; then
          usage
        fi
        shift ; shift ;;
    "-w"|"--wait")
        WAIT_DURATION=$2
        if [ "${WAIT_DURATION}" = "" ] ; then
          usage
        fi
        shift ; shift ;;
    *) usage ;;
  esac
done

#--- Unpause pipelines and jobs
unpauseJobs() {
  pipeline="$1-depls-bosh-generated"
  team="$1-depls"

  #--- Switch to team associated with pipeline
  fly -t concourse etg -n ${team} > /dev/null 2>&1
  active_pipelines="$(fly -t concourse ps | awk '{printf(" %s ", $1)}')"
  status=$(echo " ${active_pipelines} " | grep " ${pipeline} ")

  if [ "${status}" != "" ] ; then
    display "INFO" "Unpause pipeline \"${pipeline}\" jobs"
    fly -t concourse up -p ${pipeline} > /dev/null 2>&1
    activeJobs="$(fly -t concourse js -p ${pipeline} | awk '{print $1}')"
    EXCLUDED_JOBS="deploy-nexus deploy-internet-proxy deploy-gitlab deploy-concourse deploy-credhub-ha ${EXCLUDED_JOBS}"
    for job in ${activeJobs} ; do
      status=$(echo " ${EXCLUDED_JOBS} " | grep " ${job} ")
      if [ "${status}" = "" ] ; then
        printf " - %s\n" "${job}"
        fly -t concourse uj -j ${pipeline}/${job} > /dev/null 2>&1
        if [ "${WAIT_DURATION}" != "" ] ; then
          sleep ${WAIT_DURATION}
        fi
      fi
    done
  else
    display "ERROR" "Pipeline \"${pipeline}\" unknown"
  fi
}

#--- Log to concourse with fly cli
printf "\n\n%bLog to fly%b\n" "${GREEN}${BOLD}" "${STD}"
CONCOURSE_URL="${CONCOURSE_URL:-https://elpaaso-concourse.${OPS_DOMAIN}}"
export FLY_USER=$(getValue ${FLY_CREDENTIALS} "/concourse-micro-depls-username")
export FLY_PWD=$(getValue ${FLY_CREDENTIALS} "/concourse-micro-depls-password")

fly -t concourse login -c ${CONCOURSE_URL} -k -u ${FLY_USER} -p ${FLY_PWD}

#--- Identify BOSH director
if [ "${PIPELINES}" != "" ] ; then
  for bosh_pipeline in ${PIPELINES} ; do
    unpauseJobs "${bosh_pipeline}"
  done
else
  flag=0
  while [ ${flag} = 0 ]
  do
    clear
    printf "%bSelect pipeline to unpause :%b\n\n" "${REVERSE}${GREEN}" "${STD}"
    printf "%b1%b : micro\n" "${GREEN}${BOLD}" "${STD}"
    printf "%b2%b : master\n" "${GREEN}${BOLD}" "${STD}"
    printf "%b3%b : ops\n" "${GREEN}${BOLD}" "${STD}"
    printf "%b4%b : coab\n" "${GREEN}${BOLD}" "${STD}"
    printf "%b5%b : kubo\n" "${GREEN}${BOLD}" "${STD}"
    printf "%bq%b : Quit\n" "${GREEN}${BOLD}" "${STD}"
    printf "\n%bYour choice :%b " "${GREEN}${BOLD}" "${STD}" ; read choice
    case "${choice}" in
      1) unpauseJobs "micro" ;;
      2) unpauseJobs "master" ;;
      3) unpauseJobs "ops" ;;
      4) unpauseJobs "coab" ;;
      5) unpauseJobs "kubo" ;;
      q) printf "\n" ; exit ;;
    esac
  done
fi

printf "\n"