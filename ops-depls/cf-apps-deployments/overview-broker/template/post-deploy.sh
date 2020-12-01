#!/bin/bash
# Hint: short circuit beginning of pipeline using Fly hijack
# and run scripts-resource/concourse/tasks/post_deploy/run.sh

# Necessary to lookup secrets using fetch_deployment_secret_prop function
# https://github.com/koalaman/shellcheck/wiki/SC1090
# shellcheck source=common-lib.bash
source ${BASE_TEMPLATE_DIR}/common-lib.bash

DEPLOYMENT_NAME=$(extract_deployment_name)
export DEPLOYMENT_NAME

export BROKER_NAME="overview-broker"
export BROKER_APP_NAME="overview-broker"

export CF_SMOKE_TEST_SPACE="overview-broker-smoke-tests"

#Default in overview-broker, see https://github.com/cloudfoundry/overview-broker#configuration
#Nothing useful to collect in overview dashboard
#No much harm can be done by invoking overview directly or using overview dashboard: reset catalog and hijack existing service.
#Care should rather be taken by operators to not trust this service catalog and not enable/register into user-facing Osb clients
export BROKER_USER_NAME="admin"        #credential_leak_validated
export BROKER_USER_PASSWORD="password" #credential_leak_validated

# otherwise assume no probe app (e.g. FPC http reverse proxy)
export SERVICE_PROBE_APP_GIT_REPO_URL=""

#2020-10-16 10:37:40.410 TRACE 32 --- [or-http-epoll-6] o.s.c.g.filter.GatewayMetricsFilter      : gateway.requests tags: [tag(httpMethod=GET),tag(httpStatusCode=401),tag(outcome=CLIENT_ERROR),tag(routeId
EXCLUDE_REXEXP_FROM_ERROR_LOGS=' TRACE .*outcome=CLIENT_ERROR'
export EXCLUDE_REXEXP_FROM_ERROR_LOGS

export DASHBOARD_IS_EXPECTED="true"

function assert_create_service_instance() {
  echo_header "asserting that overview-broker recorded OSB calls"
  TEST_BROKER_URL="https://overview-broker."$(bosh int "${SHARED_SECRETS}" --path /secrets/cloudfoundry/system_domain)
  #Note: can't use the BROKER_URL (i.e. osb-reverse-proxy.internal-controlplane-cf.paas) because only v2/** requests are authorized by osb-reverse-proxy
  assert_curl_returns_200 -u "admin:password" ${TEST_BROKER_URL}/dashboard
  #cat /tmp/curlResponseOutput | grep '"url"'
  # expecting (more recent requests first):
  #  <span class="key">"url":</span> <span class="string">"/v2/service_instances/b9265250-017b-445f-9b29-86bd426786d7/last_operation?plan_id=78821ffd-ed1a-4d29-a3d2-d1713b6bb117&amp;service_id=7799e59d-79ca-4398-b714-c685cf66d4a9"</span>,
  #  <span class="key">"url":</span> <span class="string">"/v2/service_instances/b9265250-017b-445f-9b29-86bd426786d7/last_operation?plan_id=78821ffd-ed1a-4d29-a3d2-d1713b6bb117&amp;service_id=7799e59d-79ca-4398-b714-c685cf66d4a9"</span>,
  #  <span class="key">"url":</span> <span class="string">"/v2/service_instances/b9265250-017b-445f-9b29-86bd426786d7?accepts_incomplete=true&amp;plan_id=78821ffd-ed1a-4d29-a3d2-d1713b6bb117&amp;service_id=7799e59d-79ca-4398-b714-c685cf66d4a9"</span>,
  #  <span class="key">"url":</span> <span class="string">"/v2/service_instances/b9265250-017b-445f-9b29-86bd426786d7/service_bindings/68cd08b0-188c-43b5-a8d0-f5c308297f6f?plan_id=78821ffd-ed1a-4d29-a3d2-d1713b6bb117&amp;service_id=7799e59d-79ca-4398-b714-c685cf66d4a9"</span>,
  #  <span class="key">"url":</span> <span class="string">"/v2/service_instances/b9265250-017b-445f-9b29-86bd426786d7/service_bindings/68cd08b0-188c-43b5-a8d0-f5c308297f6f"</span>,
  #...
  local osb_calls
  osb_calls=$(cat /tmp/curlResponseOutput | grep '"url"' | cut -d'"' -f 8)
  # expecting:
  # /v2/service_instances/b9265250-017b-445f-9b29-86bd426786d7/last_operation?plan_id=78821ffd-ed1a-4d29-a3d2-d1713b6bb117&amp;service_id=7799e59d-79ca-4398-b714-c685cf66d4a9
  # /v2/service_instances/b9265250-017b-445f-9b29-86bd426786d7/last_operation?plan_id=78821ffd-ed1a-4d29-a3d2-d1713b6bb117&amp;service_id=7799e59d-79ca-4398-b714-c685cf66d4a9
  # /v2/service_instances/b9265250-017b-445f-9b29-86bd426786d7?accepts_incomplete=true&amp;plan_id=78821ffd-ed1a-4d29-a3d2-d1713b6bb117&amp;service_id=7799e59d-79ca-4398-b714-c685cf66d4a9
  # /v2/service_instances/b9265250-017b-445f-9b29-86bd426786d7/service_bindings/68cd08b0-188c-43b5-a8d0-f5c308297f6f?plan_id=78821ffd-ed1a-4d29-a3d2-d1713b6bb117&amp;service_id=7799e59d-79ca-4398-b714-c685cf66d4a9
  # /v2/service_instances/b9265250-017b-445f-9b29-86bd426786d7/service_bindings/68cd08b0-188c-43b5-a8d0-f5c308297f6f

  echo "overview dashboard received OSB calls: \n${osb_calls}"
}
export -f assert_create_service_instance

${BASE_TEMPLATE_DIR}/common-post-deploy.sh
