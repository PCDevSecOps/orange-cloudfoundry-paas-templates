#!/bin/bash
#=================================================================================
# Restart all CF applications from a specific CF organization
# To be used from docker-bosh-cli (use log-cf before executing this script)
#=================================================================================

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'
export REVERSE='\033[7m'

display() {
	case "$1" in
  	"TITLE") printf "\n%b%s :\n%b" "${REVERSE}${YELLOW}" "$2" "${STD}" ;;
		"INFO") printf "%b%s...\n%b" "${YELLOW}" "$2" "${STD}" ;;
		"ERROR") printf "\n%b%s.\n\n%b" "${REVERSE}${RED}" "$2" "${STD}" ;;
	esac
}

cfCurl() {
  value=$(cf curl $1)
  result=$(echo "${value}" | jq -r '.errors + .error_code')
  if [ "${result}" != "null" ] ; then
    display "ERROR" "\"cf curl $1\" failed"
    echo "${value}" | jq
    if [ "$2" != "bypass" ] ; then
      exit 1
    fi
  fi
}

#--- Select organization
cf config --locale en-US
ORG_NAMES=$(cf orgs | sed -e "1,3d")
display "TITLE" "Choose your organization"
printf "${ORG_NAMES}\n%bOrganization name:%b " "${REVERSE}${YELLOW}" "${STD}" ; read orgName
flag=$(echo "${ORG_NAMES}" | sed -e "s+$+ +g" | grep "${orgName} ")
if [ "${flag}" = "" ] ; then
  display "ERROR" "Target organization \"${orgName}\" unknown"
  exit 1
fi

cf t -o ${orgName} > /dev/null 2>&1
if [ $? != 0 ] ; then
  display "ERROR" "Use \"log-cf\" tool"
  exit 1
fi

#--- Restart all CF applications excepted those already stopped
display "TITLE" "You will restart active CF applications in \"${orgName}\" organization"
printf "%bDo you want to continue (y/n):%b " "${REVERSE}${YELLOW}" "${STD}" ; read choice
if [ "${choice}" != "y" ] ; then
  exit 1
fi

cf t -o ${orgName} > /dev/null 2>&1
numPage=0
nbPages=1
cfCurl "v3/organizations?page=1&per_page=1000"
orgGuid=$(echo "${value}" | jq -r --arg ORG "${orgName}" '.resources|.[]|select(.name == $ORG)|.guid')

while [ ${numPage} -lt ${nbPages} ] ; do
  ((numPage++))
  cfCurl "v3/apps?organization_guids=${orgGuid}&page=${numPage}&per_page=1000"
  nbPages=$(echo "${value}" | jq -r '.pagination|.total_pages')
  appsStatus=$(echo "${value}" | jq -r '.resources|.[]|.state + "|" + .name + "|" + .guid + "|" + .relationships.space.data.guid')
  nbAppsToRestart=$(echo "${appsStatus}" | grep "STARTED" | wc -w)
  cpt=0

  for appStatus in ${appsStatus} ; do
    appDesiredStatus=$(echo "${appStatus}" | cut -d'|' -f1)
    appName=$(echo "${appStatus}" | cut -d'|' -f2)
    appGuid=$(echo "${appStatus}" | cut -d'|' -f3)
    spaceGuid=$(echo "${appStatus}" | cut -d'|' -f4)

    if [ "${appDesiredStatus}" = "STARTED" ] ; then
      ((cpt++))
      display "INFO" "- [Lot ${numPage}/${nbPages}] Restart application [${cpt}/${nbAppsToRestart}] \"${appName}\""
      cfCurl "v3/apps/${appGuid}/actions/restart -X POST" "bypass"
      if [ "${result}" != "null" ] ; then
        cfCurl "v3/spaces/${spaceGuid}"
        spaceName=$(echo "${value}" | jq -r '.name')
        display "ERROR" "Restart of \"${appName}\" in space \"${spaceName}\" failed"
      else
        #--- Delay apps restart for infrastructure payload
        sleep 1
      fi
    fi
  done
done
printf "\n"