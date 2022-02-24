#!/bin/bash
#===========================================================================

set -o errexit # exit on errors
#set -x

echo "executing $0"
echo "This script is designed to be run within paas-templates build cycles, not at runtime"
echo "Possibly run it from a concourse pre-deploy.sh task container with ./template-resource/shared-operators/coab/coa-hooks/test-extract-x-osb-cmdb-params-for-coab.bash"
GENERATE_DIR=/tmp

# $1: expected content to assert
function assert_expected_content() {
  $(dirname $0)/extract-x-osb-cmdb-params-for-coab.bash
  extracted_file="${GENERATE_DIR}/extracted-osb-cmdb-params-for-coab-vars.yml"
  # interpolate the vars file so that duplicate keys and comments gets removed
  bosh_interpolated_vars_file=$(bosh int ${extracted_file})
  local expected_content="$1"
  echo "${expected_content}" > /tmp/expected_content.yml
  bosh int /tmp/expected_content.yml > /tmp/normalized_expected_content.yml
  local normalized_expected_content
  normalized_expected_content=$(cat /tmp/normalized_expected_content.yml)
  if [ "${bosh_interpolated_vars_file}" != "${normalized_expected_content}" ];
  then
    echo "FAIL expecting:"
    echo "${normalized_expected_content}"
    echo "but got:"
    echo "${bosh_interpolated_vars_file}"
    false
  else
    echo "PASS"
  fi
}


cat << EOF > ${GENERATE_DIR}/coab-vars-without-x-osb-cmdb.yml
---
deployment_name: "x_48f25224-c997-4d56-ab86-f6f2e0aa1219"
instance_id: "48f25224-c997-4d56-ab86-f6f2e0aa1219"
service_id: "noop-ondemand-service"
plan_id: "noop-ondemand-plan"
context:
  platform: "cloudfoundry"
  user_guid: "321ae0c8-1289-4e49-9aa4-4fca806754f1"
  space_guid: "41450901-d400-47f8-aab4-f3095c18ac72"
  organization_guid: "018ee7d1-c4d4-4975-84e9-f92610ef5306"
parameters:
maintenance_info:
  version: "49.0.1"
  description: "Dashboard url with backing service guids"
EOF

cp ${GENERATE_DIR}/coab-vars-without-x-osb-cmdb.yml ${GENERATE_DIR}/coab-vars.yml
read -r -d '' expected_default_values <<'EOF' || true
osb_client_cf_instance_name: ""
osb_client_cf_org_name: ""
osb_client_cf_organization_guid: ""
osb_client_cf_space_guid: ""
osb_client_cf_space_name: ""
osb_client_cf_user_guid: ""
osb_client_k8s_namespace: ""
osb_client_k8s_user: ""
osb_client_k8s_user_name: "" # credential_leak_validated
osb_client_orange_annotation_basicat: ""
osb_client_orange_annotation_entity: ""
osb_client_orange_annotation_orangecarto: ""
osb_client_orange_annotation_mod26e: ""
osb_client_orange_annotation_production: ""
osb_client_platform: ""
osb_client_service_guid: ""
EOF

assert_expected_content "${expected_default_values}" #no key extracted

cat << EOF > ${GENERATE_DIR}/coab-vars-with-client-annotations.yml
---
deployment_name: "x_48f25224-c997-4d56-ab86-f6f2e0aa1219"
instance_id: "48f25224-c997-4d56-ab86-f6f2e0aa1219"
service_id: "noop-ondemand-service"
plan_id: "noop-ondemand-plan"
context:
  platform: "cloudfoundry"
  user_guid: "321ae0c8-1289-4e49-9aa4-4fca806754f1"
  space_guid: "41450901-d400-47f8-aab4-f3095c18ac72"
  organization_guid: "018ee7d1-c4d4-4975-84e9-f92610ef5306"
parameters:
  x-osb-cmdb:
    annotations:
      brokered_service_context_spaceName: "smoke-tests"
      brokered_service_context_organizationName: "osb-cmdb-brokered-services-org-client-0"
      brokered_service_client_name: "osb-cmdb-backend-services-org-client-0"
      brokered_service_api_info_location: "api.redacted-domain.org/v2/info"
      brokered_service_context_instanceName: "osb-cmdb-broker-0-smoketest-1625002842"

      # osb-cmdb formats as serialized Json and expecting paas-templates to ignore this.
      # This example keys are therefore not maintained to be consistent with corresponding brokered_service_context_orange_ keys below
      brokered_service_context_organization_annotations: "{\"domain.com/org-key1\":\"org-value1\",\"orange.com/production\":\"false\"}"
      brokered_service_context_space_annotations: "{\"domain.com/space-key1\":\"space-value1\",\"orange.com/production\":\"true\"}"
      brokered_service_context_instance_annotations: "{}"
    labels:
      brokered_service_instance_guid: "0529a763-95da-41a5-a2f9-f644ffd9411a"
      brokered_service_context_organization_guid: "c2169b61-9360-4d67-968c-575f3a10edf5"
      brokered_service_originating_identity_user_id: "0d02117b-aa21-43e2-b35e-8ad6f8223519"
      brokered_service_context_space_guid: "1a603476-a3a1-4c32-8021-d2a7b9b7c6b4"

      # osb-cmdb extracts annotations prefixed by orange.com/ in the following keys:
      brokered_service_context_orange_basicat: "ABC"
      brokered_service_context_orange_entity: "OF.DTSI.ABCD.EFGH.IJKL"
      brokered_service_context_orange_mod26e: "APP012345"
      brokered_service_context_orange_orangecarto: "12345"
      brokered_service_context_orange_production: "true"
maintenance_info:
  version: "49.0.1"
  description: "Dashboard url with backing service guids"
EOF

# Note that invalid chars are instead rejected in coab to provide user feedback
#          "orange.com/a-risky-key-with-injections": "a key with backslash \ntop-key:top-value  or XSS <script>alert(''XSS'')</script>"

#See https://yaml.org/spec/1.2/spec.html#id2760844 for yaml single quoted scalars (i.e. escaping single quotes)

 # Note: read exit status is non zero when reaching EOF, so we are applying a logical OR with true
  # $ read --help
  # [...]
  #  The return code is zero, unless end-of-file is encountered, read times out
  #    (in which case it's greater than 128), a variable assignment error occurs,
  #    or an invalid file descriptor is supplied as the argument to -u.
read -r -d '' expected_extracted_annotations <<'EOF' || true
osb_client_cf_instance_name: osb-cmdb-broker-0-smoketest-1625002842
osb_client_cf_org_name: osb-cmdb-brokered-services-org-client-0
osb_client_cf_organization_guid: c2169b61-9360-4d67-968c-575f3a10edf5
osb_client_cf_space_guid: 1a603476-a3a1-4c32-8021-d2a7b9b7c6b4
osb_client_cf_space_name: smoke-tests
osb_client_cf_user_guid: 0d02117b-aa21-43e2-b35e-8ad6f8223519
osb_client_k8s_namespace: ""
osb_client_k8s_user: ""
osb_client_k8s_user_name: "" # credential_leak_validated
osb_client_orange_annotation_basicat: "ABC"
osb_client_orange_annotation_entity: "OF.DTSI.ABCD.EFGH.IJKL"
osb_client_orange_annotation_orangecarto: "12345"
osb_client_orange_annotation_mod26e: "APP012345"
osb_client_orange_annotation_production: "true"
osb_client_platform: ""
osb_client_service_guid: 0529a763-95da-41a5-a2f9-f644ffd9411a
EOF

cp ${GENERATE_DIR}/coab-vars-with-client-annotations.yml ${GENERATE_DIR}/coab-vars.yml

assert_expected_content "${expected_extracted_annotations}"
