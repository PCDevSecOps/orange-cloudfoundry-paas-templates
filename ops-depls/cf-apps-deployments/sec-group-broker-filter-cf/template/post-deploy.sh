#!/bin/bash
# Hint: short circuit beginning of pipeline using Fly hijack
# and run scripts-resource/concourse/tasks/post_deploy/run.sh

# Necessary to lookup secrets using fetch_deployment_secret_prop function
# https://github.com/koalaman/shellcheck/wiki/SC1090
# shellcheck source=common-lib.bash
source ${BASE_TEMPLATE_DIR}/common-lib.bash

DEPLOYMENT_NAME=$(extract_deployment_name)
export DEPLOYMENT_NAME

export BROKER_NAME="p-redis"
#BROKER_NAME="${BROKER_NAME:-p-coab-${COAB_SERVICE}}"

export BROKER_APP_NAME="redis-sec-group-broker-filter"
#CF_BROKER_SPACE=${CF_BROKER_SPACE:-${DEPLOYMENT_NAME}}

export CF_BROKER_SPACE="${CF_SPACE}"
#CF_BROKER_SPACE=${CF_BROKER_SPACE:-${DEPLOYMENT_NAME}}

export CF_SMOKE_TEST_SPACE="sec-group-cf-redis"

#needs to remain consistent with ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-redis-sec.tf
export BROKER_USER_NAME="admin" # credential_leak_validated

# Use same password as p-redis as to remain consistent with ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-redis-sec.tf
BROKER_USER_PASSWORD=$(fetch_deployment_secret_prop "cloudfoundry/service_brokers/p-redis/password")
#BROKER_USER_PASSWORD=$(fetch_deployment_secret_prop "cloudfoundry.service_brokers.p-redis.password")}
export BROKER_USER_PASSWORD
#BROKER_USER_PASSWORD=$(fetch_shared_secret_prop "/secrets/cloudfoundry/service_brokers/${DEPLOYMENT_NAME}/password")
#export BROKER_USER_PASSWORD_CREDHUB_KEY="/bosh-ops/cf-redis/broker-password"  #needs to remain consistent with ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-redis-sec.tf

#allow renaming of the service name used in smoke tests in secrets
SERVICE_SPECIFIED_IN_SECRETS=$(fetch_deployment_secret_prop "smoke_test_service" "missing-property")
if [[ "${SERVICE_SPECIFIED_IN_SECRETS}" -eq "missing-property" ]]; then
  #If not overriden, then set it to p-redis
  export SERVICE="p-redis"
fi
export PLAN="shared-vm"


#Use some of smoke tests variables that defines the env vars necessary to assert
# redis broker
export SERVICE_PROBE_APP_GIT_REPO_URL=https://github.com/orange-cloudfoundry/cf-redis-example-app
export LOCAL_REPOSITORY=cf-service-probe-app
export PROBE_VERB_SETTING=PUT
export PROBE_VERB_CLEARING=DELETE
export PROBE_URL_CONTEXT="foo -d data=bar"
#export SERVICE_PROBE_APP_GIT_TAG=master
export SERVICE_PROBE_APP_GIT_TAG=coab-rubybuilpack-1-8-12

# $1: service instance name
# $2: service key name
function assert_create_service_key() {
  local service_instance_name=$1
  local service_key_name=$2

  echo_header " sec-group-broker ASG on service key provisioning"

  #cf service-key SERVICE_INSTANCE SERVICE_KEY
  local service_key_guid=$(cf service-key $service_instance_name $service_key_name --guid)

  echo "Expecting ASG named after service key guid=$service_key_guid (matching service_instance_name=$service_instance_name and service_key_name=$service_key_name)"
  echo "Please manually verify content of the ASG"
  echo ""

  run_with_traces cf security-group $service_key_guid

  echo
}
export -f assert_create_service_key

# $1: service instance name
# $2: service key name
function assert_delete_service_key() {
  local service_instance_name=$1
  local service_key_name=$2

  echo_header " sec-group-broker ASG on service key deprovisioning"

  run_with_traces cf space ${CF_SMOKE_TEST_SPACE}
  echo

  #cf service-key SERVICE_INSTANCE SERVICE_KEY
  local service_key_guid=$(cf service-key $service_instance_name $service_key_name --guid || echo "none")
  local asg_msg="ASG named after service key guid (matching service_instance_name=$service_instance_name and service_key_name=$service_key_name) when service key was removed"
  if [[ -n "$service_key_guid" && "$service_key_guid" != "none" ]]; then
    echo "Expecting no $asg_msg"
    false # fail script when strict mode enabled
  else
    echo "OK. No more $asg_msg"
  fi
}
export -f assert_delete_service_key

# run smoke test
${BASE_TEMPLATE_DIR}/common-post-deploy.sh



