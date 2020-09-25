#!/bin/sh

set -o errexit # fail fast: exit on errors

#Disable use of a probe, since noop don't need them
export SERVICE_PROBE_APP_GIT_REPO_URL=""

PARENT_DIR=$(basename $(dirname ${BASE_TEMPLATE_DIR})) # expecting coa-cassandra-broker


#Proceed with common coab broker steps
${BASE_TEMPLATE_DIR}/common-post-deploy.sh
