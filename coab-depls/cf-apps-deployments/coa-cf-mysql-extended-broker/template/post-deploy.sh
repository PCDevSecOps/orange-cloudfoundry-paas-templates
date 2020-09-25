#!/bin/sh

export SERVICE_CONFIGURATION_PARAMETERS="{\"read-only\": false}"
export SERVICE_PROBE_APP_GIT_REPO_URL=https://github.com/cloudfoundry-incubator/cf-mysql-acceptance-tests
export LOCAL_REPOSITORY=cf-service-probe-app
export LOCAL_REPOSITORY_APP="${LOCAL_REPOSITORY}/assets/sinatra_app"
export PROBE_ARGUMENT="-d bar"
export PROBE_VERB_CLEARING=GET
export PROBE_URL_CONTEXT=service/mysql
export SERVICE_PROBE_APP_GIT_TAG=master
export PLAN=medium

#Proceed with common coab broker steps
${BASE_TEMPLATE_DIR}/common-post-deploy.sh