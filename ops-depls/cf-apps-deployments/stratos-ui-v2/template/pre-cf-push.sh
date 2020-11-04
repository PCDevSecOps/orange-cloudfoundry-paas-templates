#!/bin/sh

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'


#RELEASE='stable' #latest stable build
RELEASE='3.1.0' #latest stable build
#RELEASE='v2-master' #currently using HEAD on fe-int to track unreleased improvements


#--- Clone Suze Stratos V2 repository
printf "%bClone Stratos V2 Release with branch/tag=${RELEASE} ...%b\n" "${YELLOW}" "${STD}"
git clone -b ${RELEASE} --single-branch --depth 1   https://github.com/cloudfoundry-incubator/stratos  ${GENERATE_DIR}/stratos-ui-v2
result=$?
if [ "${result}" != "0" ] ; then
	printf "\n%bERROR: Clone Stratos V2 not achieved%b\n\n" "${RED}" "${STD}"
	exit 1
fi

printf "%bCurrent stratos commit, and last commit:%b\n" "${YELLOW}" "${STD}"
cd ${GENERATE_DIR}/stratos-ui-v2
git rev-parse HEAD
# pipe to cat to avoid shell asking for standard input confirmation
git log -n 1 | cat

#enhance stratos diagnostic page by collecting git info that get skipped during cf push,
# see https://docs.cloudfoundry.org/devguide/deploy-apps/prepare-to-deploy.html#exclude
./build/store-git-metadata.sh

apk add npm
# Pre-building the UI
# see https://github.com/cloudfoundry-incubator/stratos/tree/v2-master/deploy/cloud-foundry#pre-building-the-ui

#see https://stackoverflow.com/questions/56355499/stop-angular-cli-asking-for-collecting-analytics-when-i-use-ng-build
export NG_CLI_ANALYTICS=ci

#see https://support.circleci.com/hc/en-us/articles/360009208393-How-can-I-increase-the-max-memory-for-Node-
export NODE_OPTIONS=--max_old_space_size=4096

npm install
npm run prebuild-ui

ORANGE_BRANDING=false  # see https://github.com/orange-cloudfoundry/orange-component-CF-UI2/issues/1
if [ "$ORANGE_BRANDING" == "true" ]
then

    #--- Clone Rebranding repository
    printf "%bClone orange-branding...%b\n" "${YELLOW}" "${STD}"
    MISC_DIR=${GENERATE_DIR}/stratos-ui-v2/src/frontend/misc
    rm -rf ${MISC_DIR}/custom > /dev/null 2>&1
    git clone --depth 1  https://github.com/orange-cloudfoundry/orange-component-CF-UI2 ${MISC_DIR}/custom
    result=$?
    if [ "${result}" != "0" ] ; then
        printf "\n%bERROR: Clone rebranding project not achieved%b\n\n" "${RED}" "${STD}"
        exit 1
    fi
    rm -fr ${MISC_DIR}/custom/.git > /dev/null 2>&1
else
    printf "%bSkipped orange-branding%b\n" "${YELLOW}" "${STD}"
fi

#--- Create Org and Space for CF push
printf "%bCreate Space \"${CF_SPACE}\" in org \"${CF_ORG}\" for Stratos V2...%b\n" "${YELLOW}" "${STD}"
cf create-space "${CF_SPACE}" -o "${CF_ORG}"
cf bind-security-group cf-ssh-internal $CF_ORG $CF_SPACE
cf target -s "${CF_SPACE}" -o "${CF_ORG}"
