#!/bin/sh

export SERVICE_PROBE_APP_GIT_REPO_URL=https://github.com/orange-cloudfoundry/rabbit-example-app
export PROBE_VERB_CLEARING=GET
export PROBE_URL_CONTEXT=queues/test
export PROBE_ARGUMENT="-d bar"
export DEBUG_MODE=true

#Proceed with common coab broker steps
${BASE_TEMPLATE_DIR}/common-post-deploy.sh
