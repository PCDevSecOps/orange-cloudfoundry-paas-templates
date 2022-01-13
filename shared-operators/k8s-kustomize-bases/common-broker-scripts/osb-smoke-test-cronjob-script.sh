#!/bin/bash

#Usage: post-deploy.sh                      #rely on default service name extracted from current path
#Usage: COAB_SERVICE=<produit> post-deploy.sh #explicitly specify service

# Hint: short circuit beginning of pipeline using Fly hijack
# and run DEBUGGING_HINT_CMD below:

export DEBUGGING_HINT_CMD="$0"

#If undefined would fail trying to access secrets
export DEBUG_MODE=false
#export DEBUG_MODE=true


# Set up proxy environment like on concourse containers
# Our scripts unexport the proxy when reaching the intranet
export http_proxy=http://system-internet-http-proxy.internal.paas:3128
export https_proxy=http://system-internet-http-proxy.internal.paas:3128
# The list of no proxy in concourse is very long. Simplify it with the intranet tld
# More about golang no_proxy syntax in https://bosh.io/docs/cli-global-flags/#http-proxy
INTRANET_TLD=$(echo $CF_API_URL | sed "s#https://api.##g" | cut -d. -f 2-)
export no_proxy=${INTRANET_TLD}

set -o errexit                                   # exit on errors

echo "BASE_TEMPLATE_DIR is ${BASE_TEMPLATE_DIR}" # expecting coab-depls/cf-apps-deployments/coa-<produit>-broker/template
#echo "BASE_TEMPLATE_DIR is ${BASE_TEMPLATE_DIR}" # expecting coab-depls/cf-apps-deployments/coa-<produit>-broker/template
script="/scripts/common-lib.bash"
# https://github.com/koalaman/shellcheck/wiki/SC1090
# shellcheck source=common-lib.bash
source "${script}"
set_verbose_mode_as_requested_in_secrets

#Sleep on exit in addition to trapping ERR with diagnostics
function sleep_on_exit() {
  SLEEP_TIME=$((5*60))
  echo "sleeping ${SLEEP_TIME} seconds to leave the container ready for inspection"
  sleep ${SLEEP_TIME}
}
trap 'sleep_on_exit' EXIT

if [ "$DEBUG_MODE" == "true" ]; then
  env
  pwd
fi


log_in_to_cf
setup_smoke_test_space_and_org

clean_up_leaking_services


# Provisioning (asynchronous) variables
SERVICE_INSTANCE="$(generate_unique_prefixed_name "${SERVICE_INSTANCE_PREFIX}")"
export SERVICE_INSTANCE # required for this variable to be used by envsubst spawned command


perform_broker_registration_or_update_when_requested

display_service_in_marketplace

test_service_provisionning

assert_dashboard "${SERVICE_INSTANCE}" "${DASHBOARD_IS_EXPECTED}" "${DASHBOARD_AUTH_IS_EXPECTED}"

#Allow injection of additional assertions from callers, such as osb-cmdb checking backing services
if function_exists_or_defined_in_secrets assert_create_service_instance; then
  assert_create_service_instance "${SERVICE_INSTANCE}"
fi

test_service_key

PROBE_HOST="${COAB_SERVICE}-service-probe-app"

test_service_binding
test_service_deprovisionning


if function_exists_or_defined_in_secrets assert_broker_actuator_endpoints; then
  assert_broker_actuator_endpoints
fi

echo
echo_header "Smoke test successful :-)"
