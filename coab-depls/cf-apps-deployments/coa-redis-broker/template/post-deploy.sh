#!/bin/sh

export SERVICE_PROBE_APP_GIT_REPO_URL=https://github.com/orange-cloudfoundry/cf-redis-example-app
export LOCAL_REPOSITORY=cf-service-probe-app
export PROBE_VERB_SETTING=PUT
export PROBE_VERB_CLEARING=DELETE
export PROBE_URL_CONTEXT="foo -d data=bar"
export PLAN=small
export SERVICE_PROBE_APP_GIT_TAG=coab-rubybuilpack-1-8-12

#Load coab defaults
source ${BASE_TEMPLATE_DIR}/coab-post-deploy-defaults.bash

#Proceed with common broker steps
${BASE_TEMPLATE_DIR}/common-post-deploy.sh