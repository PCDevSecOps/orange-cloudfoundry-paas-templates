#!/bin/bash

export PLAN=small
#export DEBUG_MODE=true # Please, favor using secrets for turning on debug mode

export SERVICE_PROBE_APP_GIT_REPO_URL=https://github.com/orange-cloudfoundry/cf-mongodb-example-app
export SERVICE_PROBE_APP_GIT_TAG=hamode
export DASHBOARD_IS_EXPECTED=false

#Load coab defaults
source ${BASE_TEMPLATE_DIR}/coab-post-deploy-defaults.bash

#Proceed with coab broker steps
${BASE_TEMPLATE_DIR}/common-post-deploy.sh
