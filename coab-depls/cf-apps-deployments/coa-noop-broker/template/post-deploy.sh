#!/bin/sh

set -o errexit # fail fast: exit on errors

#Disable use of a probe, since noop don't need them
export SERVICE_PROBE_APP_GIT_REPO_URL=""

PARENT_DIR=$(basename $(dirname ${BASE_TEMPLATE_DIR})) # expecting coa-cassandra-broker

#Load coab defaults
source ${BASE_TEMPLATE_DIR}/coab-post-deploy-defaults.bash

#Proceed with common broker steps
${BASE_TEMPLATE_DIR}/common-post-deploy.sh
