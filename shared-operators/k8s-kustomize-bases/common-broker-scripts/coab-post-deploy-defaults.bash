#!/bin/bash
# This file contains COAB specific variable declaration and functions
# It should be sourced from coab deployments
# Progressively, the post-deploy.sh script should have sensible defaults (for osb-cmdb, sec-group)
# and not not have anymore coab-specific defaults

# Simulating x-osb-cmdb param tha osb-cmdb is providing when it fronts coab
# To ensure brokered_service_instance_guid is unique across service instances, we use the service instance name which is unique within the smoke test space
# (we can't guess in advance the guid that CF will assign to the service instance once the `cf create-service -c params.jon` request will have been sent)
# Note: Although we reference variables that will be declared later, this variable should be deferenced using envsubst
# by post-deploy.sh once its dependencies are declared
# HOWEVER all referenced variables MUST BE EXPORTED (otherwise envsubst spawnned process won't be able to deference them)

# See https://stackoverflow.com/a/1655389/1484823 for this syntax
# Note: read exit status is non zero when reaching EOF, so we are applying a logical OR with true
# $ read --help
# [...]
#  The return code is zero, unless end-of-file is encountered, read times out
#    (in which case it's greater than 128), a variable assignment error occurs,
#    or an invalid file descriptor is supplied as the argument to -u.
read -r -d '' SERVICE_INSTANCE_CONFIGURATION_PARAMETERS <<'EOF' || true
{
  "x-osb-cmdb": {
    "annotations": {
      "brokered_service_context_spaceName": "${CF_SMOKE_TEST_SPACE}",
      "brokered_service_context_organizationName": "${CF_SMOKE_TEST_ORG}",
      "brokered_service_api_info_location": "fake-endpoint/v2/info",
      "brokered_service_context_instanceName": "${SERVICE_INSTANCE}"
    },
    "labels": {
      "brokered_service_instance_guid": "${SERVICE_INSTANCE}",
      "brokered_service_originating_identity_user_id": "a-faked-user-guid-in-coab-smoke-tests",
      "brokered_service_context_organization_guid": "a-faked-org-guid-in-coab-smoke-tests",
      "brokered_service_context_space_guid": "a-faked-space-guid-in-coab-smoke-tests"
    }
  }
}
EOF
export SERVICE_INSTANCE_CONFIGURATION_PARAMETERS
