#!/bin/bash

# Hint: short circuit beginning of pipeline using Fly hijack
# and run scripts-resource/concourse/tasks/post_deploy/run.sh

# Necessary to lookup secrets using fetch_deployment_secret_prop function
# https://github.com/koalaman/shellcheck/wiki/SC1090
# shellcheck source=common-lib.bash
source ${BASE_TEMPLATE_DIR}/common-lib.bash

#Disable use of a probe, since we don't yet need them for dev tools
export SERVICE_PROBE_APP_GIT_REPO_URL=""

DEPLOYMENT_NAME=$(extract_deployment_name)
export DEPLOYMENT_NAME

BROKER_NAME="developer-tools-broker"
export BROKER_NAME
export CF_SMOKE_TEST_SPACE="${DEPLOYMENT_NAME}-smoke-tests"

#Currently used in developer-tools-broker_manifest-tpl.yml through grab secrets.developer-tools-broker.name
export BROKER_USER_NAME=$(fetch_deployment_secret_prop "developer-tools-broker/name" "missing_developer-tools-broker.name_from_secrets_file") # credential_leak_validated
BROKER_USER_PASSWORD_CREDHUB_KEY="$(default_credhub_interpolate_prefix)/broker-password"
export BROKER_USER_PASSWORD_CREDHUB_KEY

#Proceed with common broker steps
${BASE_TEMPLATE_DIR}/common-post-deploy.sh
