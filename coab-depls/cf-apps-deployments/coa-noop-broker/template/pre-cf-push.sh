#!/bin/sh

#Noop specifics: nested broker through static creds
wget https://github.com/orange-cloudfoundry/static-creds-broker/releases/download/v2.2.0.RELEASE/static-creds-broker-2.2.0.RELEASE.jar -O ${GENERATE_DIR}/static-creds-broker.jar

#Disable use of a probe, since noop don't need them
export SERVICE_PROBE_APP_GIT_REPO_URL=""

#Proceed with common coab broker steps
${BASE_TEMPLATE_DIR}/common-pre-cf-push.sh