#!/bin/bash

set -o errexit # fail fast: exit on errors

# Script is used for credhub default prefix utility function
# https://github.com/koalaman/shellcheck/wiki/SC1090
# shellcheck source=common-lib.bash
source ${BASE_TEMPLATE_DIR}/common-lib.bash
set_verbose_mode_as_requested_in_secrets

#static-creds-broker  specifics
export REPO_NAME=static-creds-broker
export JAR_ARTEFACT_BASE_NAME=static-creds-broker
export SPACE_QUOTA=developer-tools-broker-quota
export RELEASE_VERSION=2.2.0.RELEASE

# In order to support multiple symlinked osb-cmdb cf apps with distinct passwords
# we need to have per deployment credhub key
function generate_credhub_var_osb_password_request() {
   BROKER_USER_PASSWORD_CREDHUB_KEY="$(default_credhub_interpolate_prefix)/broker-password"
   CREDHUB_CREDENTIAL_REQUEST_FILE="${BASE_TEMPLATE_DIR}/credhub-var-broker-password.json"
   cat > ${CREDHUB_CREDENTIAL_REQUEST_FILE} <<EOF
        {
          "name": "${BROKER_USER_PASSWORD_CREDHUB_KEY}",
          "type": "password"
        }
EOF
    echo "Wrote credhub credential request at ${CREDHUB_CREDENTIAL_REQUEST_FILE} with content:"
    cat ${CREDHUB_CREDENTIAL_REQUEST_FILE}
}
generate_credhub_var_osb_password_request

#Download static-creds-broker.jar, generate credhub variable
${BASE_TEMPLATE_DIR}/common-pre-cf-push.sh

# COA exported variables
#    CF_USERNAME=redacted_username
#    CF_ORG=system_domain
#    CF_PASSWORD=
#    CF_API_URL=
#    CF_SPACE=osb-cmdb-broker
#    CF_MANIFEST=generated-files/osb-cmdb-broker_manifest.yml
cf t -o ${CF_ORG}
cf create-space $CF_SPACE

# TODO: static resource serving
# SECRETS_DIR=credentials-resource/ops-depls/cf-apps-deployments/developer-tools-broker
#cp -r ${SECRETS_DIR}/statics ./generated-files