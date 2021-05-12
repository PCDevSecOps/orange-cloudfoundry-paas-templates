#!/bin/bash

export SERVICE_PROBE_APP_GIT_REPO_URL=https://github.com/orange-cloudfoundry/rabbit-example-app
export SERVICE_PROBE_APP_GIT_TAG=coab-extended
export PROBE_VERB_CLEARING=GET
export PROBE_URL_CONTEXT=queues/test
export PROBE_ARGUMENT="-d bar"

#Load coab defaults
source ${BASE_TEMPLATE_DIR}/coab-post-deploy-defaults.bash

#Proceed with common broker steps
${BASE_TEMPLATE_DIR}/common-post-deploy.sh
