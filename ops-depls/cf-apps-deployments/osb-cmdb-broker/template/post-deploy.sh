#!/bin/bash
# Hint: short circuit beginning of pipeline using Fly hijack
# and run scripts-resource/concourse/tasks/post_deploy/run.sh

# Necessary to lookup secrets using fetch_deployment_secret_prop function
# https://github.com/koalaman/shellcheck/wiki/SC1090
# shellcheck source=common-lib.bash
source ${BASE_TEMPLATE_DIR}/common-lib.bash
# shellcheck source=osb-cmdb-common-lib.bash
source ${BASE_TEMPLATE_DIR}/osb-cmdb-common-lib.bash

DEPLOYMENT_NAME=$(extract_deployment_name)
export DEPLOYMENT_NAME

BROKER_NAME=$(fetch_deployment_secret_prop "broker_name" "missing_broker_name_from_secrets_file")
export BROKER_NAME
export CF_SMOKE_TEST_SPACE="smoke-tests"

#Currently used in osb-cmdb-broker_manifest-tpl.yml through grab secrets.osb-cmdb-broker.name
export BROKER_USER_NAME=$(fetch_deployment_secret_prop "osb-cmdb-broker/name" "missing_osb-cmdb-broker.name_from_secrets_file") # credential_leak_validated
BROKER_USER_PASSWORD_CREDHUB_KEY="$(default_credhub_interpolate_prefix)/broker-password"
export BROKER_USER_PASSWORD_CREDHUB_KEY
#Use some of coab-mysql smoke tests variables that defines the env vars necessary to assert
# mysql broker
export SERVICE_CONFIGURATION_PARAMETERS="{\"read-only\": false}"

SERVICE_PROBE_APP_GIT_REPO_URL_FROM_SECRETS=$(fetch_deployment_secret_prop "service_probe_app_git_repo_url" "no_url_set_in_secret")
if [[ "${SERVICE_PROBE_APP_GIT_REPO_URL_FROM_SECRETS}" != "no_url_set_in_secret" ]]; then
  #If explicitly defined in secrets including an empty value, then use it. Useful to test noop coab in fe-int, or custom service by operators
  export SERVICE_PROBE_APP_GIT_REPO_URL="${SERVICE_PROBE_APP_GIT_REPO_URL_FROM_SECRETS}"
else
  # otherwise assume mysql
  export SERVICE_PROBE_APP_GIT_REPO_URL="https://github.com/cloudfoundry-incubator/cf-mysql-acceptance-tests"
fi

export LOCAL_REPOSITORY=cf-service-probe-app
export LOCAL_REPOSITORY_APP="${LOCAL_REPOSITORY}/assets/sinatra_app"
export PROBE_ARGUMENT="-d bar"
export PROBE_VERB_CLEARING=GET
export PROBE_URL_CONTEXT=service/mysql
export SERVICE_PROBE_APP_GIT_TAG=master

function current_cf_target_cmd() {
  CF_ARGS=$(cf t | awk '/org/ {printf " -o " $2} /space/ {printf " -s " $2}')
  echo "${CF_ARGS}"
}
export -f current_cf_target_cmd


function backing_services_space() {
    # When using SpacePerServiceDefinition target, the space is the name of backing service definition target
    local SERVICE
    SERVICE=$(fetch_deployment_secret_prop "smoke_test_service" "${COAB_SERVICE}-ondemand")
    echo ${SERVICE}
    # When using ServiceInstanceGuidSuffix target, all backing services are in the same space
    # $(fetch_deployment_secret_prop "${DEPLOYMENT_NAME}/default-space" "missing-broker-default-space-from-secrets-file")"
}
export -f backing_services_space

# Builtin busy box grep is limited and missing colored output and many options
function install_gnu_grep_if_missing() {
    grep --help 2>&1 | grep 'color' &> /tmp/isGnuGrep || apk add grep &> /tmp/install-gnu-grep
}
export -f install_gnu_grep_if_missing

# The script is axternalized to be shared with docker bosh cli and osb-cmdb readme
# Workaround for COA bug not detecting submodules in cf apps
# https://github.com/orange-cloudfoundry/cf-ops-automation/issues/122
rm -rf ${BASE_TEMPLATE_DIR}/../cf-cli-cmdb-scripts
git clone https://github.com/orange-cloudfoundry/cf-cli-cmdb-scripts ${BASE_TEMPLATE_DIR}/../cf-cli-cmdb-scripts
# shellcheck source=../cf-cli-cmdb-scripts/cf-cli-cmdb-functions.bash
source ${BASE_TEMPLATE_DIR}/../cf-cli-cmdb-scripts/cf-cli-cmdb-functions.bash

# $1: service instance name
function assert_service_metadata() {
  local SERVICE_INSTANCE_NAME SERVICE_INSTANCE_GUID INITIAL_CF_ARGS_TARGET BACKING_SERVICES NB_BACKING_SERVICES

  SERVICE_INSTANCE_NAME="$1"
  SERVICE_INSTANCE_GUID=$(cf service ${SERVICE_INSTANCE_NAME} --guid)
  INITIAL_CF_ARGS_TARGET=$(current_cf_target_cmd)

  echo_header "backing service metadata"

  cf t -o "$(backing_services_org)" -s "$(backing_services_space)" > /dev/null
  BACKING_SERVICES=$(cf services)

   # Instruct users to define the function
   echo "Until CF CLI v7 supports \"cf labels service\" command, this command is available into https://github.com/orange-cloudfoundry/cf-cli-cmdb-scripts"
   echo
   for s in $(echo "${BACKING_SERVICES}" | grep ${SERVICE_INSTANCE_GUID} | awk '{print $1}' ); do
     run_with_traces cf_labels_service ${s}
   done;

  # Restore the initial target to enable possible next clean ups following this assertion
  cf target ${INITIAL_CF_ARGS_TARGET} > /dev/null
  echo
}
export -f assert_service_metadata

# $1: service instance name
# $2: nb expected service instances
function assert_service_instance_number() {
  local SERVICE_INSTANCE_NAME NB_EXPECTED_INSTANCES SERVICE_INSTANCE_GUID INITIAL_CF_ARGS_TARGET BACKING_SERVICES NB_BACKING_SERVICES

  SERVICE_INSTANCE_NAME="$1"
  NB_EXPECTED_INSTANCES="$2"
  SERVICE_INSTANCE_GUID=$(cf service ${SERVICE_INSTANCE_NAME} --guid)
  INITIAL_CF_ARGS_TARGET=$(current_cf_target_cmd)

  cf t -o "$(backing_services_org)" -s "$(backing_services_space)" > /dev/null
  BACKING_SERVICES=$(cf services)

  # Restore the initial target to enable possible next clean ups following this assertion
  cf target ${INITIAL_CF_ARGS_TARGET} > /dev/null

  printf "\nOsbCmdb backing services created (expecting ${NB_EXPECTED_INSTANCES} instance(s) matching brokered service guid ${SERVICE_INSTANCE_GUID})\n"
  install_gnu_grep_if_missing
  # Print colored grep match, see https://stackoverflow.com/a/981831/1484823
  printf "${BACKING_SERVICES}\n" | grep --color -E "${SERVICE_INSTANCE_GUID}|\$"

  NB_BACKING_SERVICES=$(echo "${BACKING_SERVICES}" | grep ${SERVICE_INSTANCE_GUID} | wc -l)
  if [[ ${NB_BACKING_SERVICES} -ne ${NB_EXPECTED_INSTANCES} ]]; then
    false # fail script when strict mode enabled
  fi
}
export -f assert_service_instance_number

# $1: service instance name
# $2: service key name
# $3: nb expected service keys
function assert_service_key_number() {
  SERVICE_INSTANCE_NAME="$1"
  SERVICE_KEY_NAME="$2"
  NB_EXPECTED_INSTANCES="$3"
  SERVICE_INSTANCE_GUID=$(cf service ${SERVICE_INSTANCE_NAME} --guid)
  INITIAL_CF_ARGS_TARGET=$(current_cf_target_cmd)

  cf t -o "$(backing_services_org)" -s "$(backing_services_space)" > /dev/null
  BACKING_SERVICE_NAME=$(cf services | grep ${SERVICE_INSTANCE_GUID} | awk '{print $1}')
  BACKING_SERVICE_KEYS=$(cf service-keys ${BACKING_SERVICE_NAME} | grep -v  'No service key for service instance\|Getting keys for service instance\|FAILED\|not found\|name' || true)
  # Restore the initial target to enable possible next clean ups following this assertion
  cf target ${INITIAL_CF_ARGS_TARGET} > /dev/null

  printf "\nOsbCmdb backing service keys created (expecting ${NB_EXPECTED_INSTANCES} instance(s))\n ${BACKING_SERVICE_KEYS} \n"
  #Workaround CF CLI bug https://github.com/cloudfoundry/cli/issues/1833
  if [[ ${NB_EXPECTED_INSTANCES} -eq 0 ]]; then
      # -n length of non zero: see https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html#Bash-Conditional-Expressions
      if [[ -n "${BACKING_SERVICE_KEYS}" ]]; then
        echo "expecting zero service keys, found: ${BACKING_SERVICE_KEYS}, failing"
        false # fail script when strict mode enabled
      fi
  else
      SERVICE_KEY_GUID=$(cf service-key  ${SERVICE_INSTANCE_NAME} ${SERVICE_KEY_NAME} --guid 2> /tmp/assert_service_key_number_trace.txt || echo "no_guid_no_service_key_found")
      NB_BACKING_SERVICE_KEYS=$(echo "${BACKING_SERVICE_KEYS}" | grep ${SERVICE_KEY_GUID} | wc -l)
      if [[ ${NB_BACKING_SERVICE_KEYS} -ne ${NB_EXPECTED_INSTANCES} ]]; then
        false # fail script when strict mode enabled
      fi
  fi
}
export -f assert_service_key_number

# $1: service instance name
function assert_create_service_instance() {
  assert_service_instance_number $1 1
  assert_service_metadata $1
}
export -f assert_create_service_instance

# $1: service instance name
# $2: service key name
function assert_create_service_key() {
  assert_service_key_number $1 $2 1
}
export -f assert_create_service_key

# $1: service instance name
# $2: service key name
function assert_delete_service_key() {
  assert_service_key_number $1 $2 0
}
export -f assert_delete_service_key


# $1: service instance name
function assert_delete_service_instance() {
  assert_service_instance_number $1 0
}
export -f assert_delete_service_instance

${BASE_TEMPLATE_DIR}/common-post-deploy.sh



