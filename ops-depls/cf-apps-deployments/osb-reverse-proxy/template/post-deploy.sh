#!/bin/bash
# Hint: short circuit beginning of pipeline using Fly hijack
# and run scripts-resource/concourse/tasks/post_deploy/run.sh

# Necessary to lookup secrets using fetch_deployment_secret_prop function
# https://github.com/koalaman/shellcheck/wiki/SC1090
# shellcheck source=common-lib.bash
source ${BASE_TEMPLATE_DIR}/common-lib.bash

DEPLOYMENT_NAME=$(extract_deployment_name)
export DEPLOYMENT_NAME

BROKER_NAME=$(fetch_deployment_secret_prop "broker_name" "missing_osb_reverse_proxy_broker_name_from_secrets_file")
export BROKER_NAME
export CF_SMOKE_TEST_SPACE="${DEPLOYMENT_NAME}-smoke-tests"

BROKER_FQDN="${BROKER_NAME}.internal-controlplane-cf.paas"
export BROKER_FQDN

#Let common broker scripts load broker user name and password from secrets
# this is the password of the backing broker (e.g. overview broker with hardcoded credentials)
#Currently used in osb-reverse-proxy_manifest-tpl.yml through grab secrets.osb-reverse-proxy.name

#The following section could be used in the future if backing service broker gets declared in credhub
#export BROKER_USER_NAME=$(fetch_deployment_secret_prop "osb-reverse-proxy/name" "missing_osb-reverse-proxy.name_from_secrets_file") # credential_leak_validated
#BROKER_USER_PASSWORD_CREDHUB_KEY="$(default_credhub_interpolate_prefix)/broker-password"
#export BROKER_USER_PASSWORD_CREDHUB_KEY
BROKER_USER_PASSWORD=${BROKER_USER_PASSWORD:-$(fetch_deployment_secret_prop "${DEPLOYMENT_NAME}/password" "missing-broker-osb-reverse-proxy-username-from-secrets-file")}
export BROKER_USER_PASSWORD

#Use some of coab-mysql smoke tests variables that defines the env vars necessary to assert
# mysql broker
#export SERVICE_CONFIGURATION_PARAMETERS="{\"read-only\": false}"

SERVICE_PROBE_APP_GIT_REPO_URL_FROM_SECRETS=$(fetch_deployment_secret_prop "service_probe_app_git_repo_url" "no_url_set_in_secret")
if [[ "${SERVICE_PROBE_APP_GIT_REPO_URL_FROM_SECRETS}" != "no_url_set_in_secret" ]]; then
  #If explicitly defined in secrets including an empty value, then use it. Useful to test overview service in fe-int, or custom service by operators
  export SERVICE_PROBE_APP_GIT_REPO_URL="${SERVICE_PROBE_APP_GIT_REPO_URL_FROM_SECRETS}"
else
  # otherwise assume no probe app (e.g. FPC http reverse proxy)
  export SERVICE_PROBE_APP_GIT_REPO_URL=""
fi

#2020-10-16 10:37:40.410 TRACE 32 --- [or-http-epoll-6] o.s.c.g.filter.GatewayMetricsFilter      : gateway.requests tags: [tag(httpMethod=GET),tag(httpStatusCode=401),tag(outcome=CLIENT_ERROR),tag(routeId
EXCLUDE_REXEXP_FROM_ERROR_LOGS=' TRACE .*outcome=CLIENT_ERROR'
export EXCLUDE_REXEXP_FROM_ERROR_LOGS

function assert_broker_actuator_endpoints() {
  local INITIAL_CF_ARGS_TARGET
  INITIAL_CF_ARGS_TARGET=$(current_cf_target_cmd)

  cf target -o "${CF_BROKER_ORG}" -s "${CF_BROKER_SPACE}" > /dev/null

  echo_header "Asserting actuator httptrace"
  local SERVICE_PROVIDER_USER
  local SERVICE_PROVIDER_PASSWORD
  SERVICE_PROVIDER_USER=$(cf env ${BROKER_APP_NAME} | grep osbreverseproxy.serviceProviderUser | awk '{print $2}')
  SERVICE_PROVIDER_PASSWORD=$(cf env ${BROKER_APP_NAME} | grep osbreverseproxy.serviceProviderPassword | awk '{print $2}')
  local ACTUATOR_ROUTE
  ACTUATOR_ROUTE=$(cf app ${BROKER_APP_NAME} | grep 'routes' | awk '{print $3}')

  # Restore the initial target to enable possible next clean ups following this assertion
  cf target ${INITIAL_CF_ARGS_TARGET} > /dev/null

  assert_curl_status_code_within "actuator httptrace endpoint unauthenticated" 300 499 "https://${ACTUATOR_ROUTE}/actuator/httptrace"
  assert_curl_status_code_within "actuator httptrace endpoint authenticated" 200 200 -u "${SERVICE_PROVIDER_USER}:${SERVICE_PROVIDER_PASSWORD}" "https://${ACTUATOR_ROUTE}/actuator/httptrace"

  echo "Displaying last httptrace recorded bodies (fist 100 chars) targetted to service consumers"
  cat /tmp/curlResponseOutput | jq . | grep -A1 '_body' | cut -c1-100

  echo "Sample commands to fetch osb-reverse-proxy traces:"
  for i in {1..5}
  do
    run_with_traces "curl --noproxy \"*\" -k --silent -u \"${SERVICE_PROVIDER_USER}:${SERVICE_PROVIDER_PASSWORD}\" \"https://${ACTUATOR_ROUTE}/actuator/httptrace\" | jq . > trace-`date +%Y-%m-%d.%H:%M:%S`.json"
  done
  run_with_traces "jq -s . trace*.json | jq -r 'unique' | jq -r '.[].traces[] | select (.request.method==\"PUT\")'"
  rm trace*.json
}
export -f assert_broker_actuator_endpoints

${BASE_TEMPLATE_DIR}/common-post-deploy.sh



