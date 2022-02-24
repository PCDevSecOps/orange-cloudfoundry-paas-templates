#!/bin/bash


# Mysql specifics
export SERVICE_CONFIGURATION_PARAMETERS="{\"read-only\": false}" #for service key
export SERVICE_PROBE_APP_GIT_REPO_URL=https://github.com/orange-cloudfoundry/cf-mysql-acceptance-tests
export LOCAL_REPOSITORY=cf-service-probe-app
export LOCAL_REPOSITORY_APP="${LOCAL_REPOSITORY}/assets/sinatra_app"
export PROBE_ARGUMENT="-d bar"
export PROBE_VERB_CLEARING=GET
export PROBE_URL_CONTEXT=service/mysql
export SERVICE_PROBE_APP_GIT_TAG=ssl-server
export PLAN=medium

export DASHBOARD_IS_EXPECTED=true

#Load coab defaults
source ${BASE_TEMPLATE_DIR}/coab-post-deploy-defaults.bash

#Proceed with common broker steps
${BASE_TEMPLATE_DIR}/common-post-deploy.sh