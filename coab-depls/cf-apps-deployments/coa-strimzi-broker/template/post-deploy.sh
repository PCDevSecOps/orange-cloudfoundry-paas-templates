#!/bin/sh

#export SERVICE_PROBE_APP_GIT_REPO_URL=https://github.com/orange-cloudfoundry/cf-redis-example-app
#export LOCAL_REPOSITORY=cf-service-probe-app
#export PROBE_VERB_SETTING=PUT
#export PROBE_VERB_CLEARING=DELETE
#export PROBE_URL_CONTEXT="foo -d data=bar"
#export PLAN=small
#export SERVICE_PROBE_APP_GIT_TAG=coab-rubybuilpack-1-8-12
#export MAX_TIME=$((180*60+30))

export SERVICE_KEY_CONFIGURATION_PARAMETERS="" #{\"read-only\": false}" #for service key
export SERVICE_PROBE_APP_GIT_REPO_URL="" #https://github.com/cloudfoundry-incubator/cf-mysql-acceptance-tests
export PROBE_VERB_CLEARING="" #GET
export PROBE_URL_CONTEXT="" #service/mysql
export SERVICE_PROBE_APP_GIT_TAG="" #master
export PLAN=small
export DASHBOARD_IS_EXPECTED=false #FIXME: should be true, but world simplest broker wont allow it ?


#Load coab defaults
source ${BASE_TEMPLATE_DIR}/coab-post-deploy-defaults.bash

#Proceed with common coab broker steps
${BASE_TEMPLATE_DIR}/common-post-deploy.sh