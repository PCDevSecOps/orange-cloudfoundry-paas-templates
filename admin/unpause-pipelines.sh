#!/bin/bash
#===========================================================================
# Unpause concourse pipelines (except  coab-depls-bosh-generated to control 
# clients dedicated services availability)
# Parameters :
# --exclude-pipelines, -e : Unpause all pipelines except list (space separated)
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

EXCLUDED_PIPELINES=""

#--- Check scripts options
usage() {
  printf "\n%bUSAGE:" "${RED}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-40s %s" "--exclude-pipelines, -e \"job list\"" "Unpause all pipelines except list (space separated)"
  printf "%b\n\n" "${STD}" ; exit 1
}

while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-e"|"--exclude-pipelines")
      EXCLUDED_PIPELINES="$2"
      if [ "${EXCLUDED_PIPELINES}" = "" ] ; then
        usage
      fi
      shift ; shift ;;
    *) usage ;;
  esac
done

#--- Log to concourse with fly cli
printf "\n\n%bLog to fly%b\n" "${GREEN}${BOLD}" "${STD}"
CONCOURSE_URL="${CONCOURSE_URL:-https://elpaaso-concourse.${OPS_DOMAIN}}"
export FLY_USER=$(getValue ${FLY_CREDENTIALS} "/concourse-micro-depls-username")
export FLY_PWD=$(getValue ${FLY_CREDENTIALS} "/concourse-micro-depls-password")
fly -t concourse login -c ${CONCOURSE_URL} -k -u ${FLY_USER} -p ${FLY_PWD}

#--- Unpause pipelines
TEAMS=$(fly -t concourse teams | head -n -1)
for team in ${TEAMS} ; do
  #--- Switch to team associated with pipeline
  fly -t concourse etg -n ${team} > /dev/null 2>&1

  #--- Check pipeline
  active_pipelines="$(fly -t concourse ps --json | jq -r '.[].name')"
  display "INFO" "Unpause team \"${team}\" pipelines"
  for pipeline in ${active_pipelines} ; do
    status=$(echo " ${EXCLUDED_PIPELINES} coab-depls-bosh-generated " | grep " ${pipeline} ")
    if [ "${status}" = "" ] ; then
      printf " - %s\n" "${pipeline}"
      fly -t concourse up -p ${pipeline} > /dev/null 2>&1
    fi
  done
done

printf "\n"