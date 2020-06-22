#!/bin/bash

#--- Deployment parameters
DEPLOYMENT="SSO sample apps"
SERVICE="o-oauth-sso-guardian"

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'

printf "%bDownload and install \"${DEPLOYMENT}\"...%b\n" "${YELLOW}" "${STD}"
curl -L -o ${GENERATE_DIR}/app-sso-sample.jar https://github.com/orange-cloudfoundry/sso/releases/download/v2.0.0-RELEASE/sso-2.0.0-RELEASE.jar 

printf "%bCreate \"${DEPLOYMENT}\" space \"${CF_SPACE}\" in org \"${CF_ORG}\"...%b\n" "${YELLOW}" "${STD}"
cf create-space "${CF_SPACE}" -o "${CF_ORG}"
cf target -s "${CF_SPACE}" -o "${CF_ORG}"

SERVICE_PLAN="qa"
SERVICE_INSTANCE="sso-qa-service"
cf s | grep ${SERVICE_INSTANCE} > /dev/null 2>&1
if [ $? != 0 ] ; then
	printf "%bCreate service instance \"${SERVICE_INSTANCE}\" based on \"${SERVICE}\" with plan \"${SERVICE_PLAN}\"...%b\n" "${YELLOW}" "${STD}"
	cf cs ${SERVICE} ${SERVICE_PLAN} ${SERVICE_INSTANCE}
	if [ $? != 0 ] ; then
		printf "\n%bERROR: \"${SERVICE_INSTANCE}\" service creation failed%b\n\n" "${RED}" "${STD}" ; exit 1
	fi
fi

SERVICE_PLAN="prod"
SERVICE_INSTANCE="sso-prod-service"
cf s | grep ${SERVICE_INSTANCE} > /dev/null 2>&1
if [ $? != 0 ] ; then
	printf "%bCreate service instance \"${SERVICE_INSTANCE}\" based on \"${SERVICE}\" with plan \"${SERVICE_PLAN}\"...%b\n" "${YELLOW}" "${STD}"
	cf cs ${SERVICE} ${SERVICE_PLAN} ${SERVICE_INSTANCE}
	if [ $? != 0 ] ; then
		printf "\n%bERROR: \"${SERVICE_INSTANCE}\" service creation failed%b\n\n" "${RED}" "${STD}" ; exit 1
	fi
	#--- Wait for asynchronous service completion (3 times 20s then exit)
	cpt=0
	while [ ${cpt} -lt 3 ] ; do
		((cpt++))
		sleep 20
		result=$(cf s | grep ${SERVICE_INSTANCE} 2> /dev/null)
		if [ "${result}" != "" ] ; then
			cpt=10
		fi
		if [ ${cpt} = 3 ] ; then
			printf "\n%bERROR: \"${SERVICE_INSTANCE}\" service creation timeout within 60s%b\n\n" "${RED}" "${STD}" ; exit 1
		fi
	done
fi
