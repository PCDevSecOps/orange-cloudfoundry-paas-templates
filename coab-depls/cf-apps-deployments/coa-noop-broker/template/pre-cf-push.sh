#!/bin/sh

set -o errexit # fail fast: exit on errors


#Noop specifics: nested broker through static creds
set -e # fail fast

URL=https://github.com/orange-cloudfoundry/static-creds-broker/releases/download/v2.2.0.RELEASE/static-creds-broker-2.2.0.RELEASE.jar
echo "Downloading artefact from ${URL}"
curl -L -s ${URL} -o ${GENERATE_DIR}/static-creds-broker.jar
ls -al ${GENERATE_DIR}/static-creds-broker.jar

#Disable use of a probe, since noop don't need them
export SERVICE_PROBE_APP_GIT_REPO_URL=""

#Proceed with common coab broker steps
${BASE_TEMPLATE_DIR}/common-pre-cf-push.sh
