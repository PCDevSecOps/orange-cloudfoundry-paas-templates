#!/bin/bash
set -o errexit #needed as not inherited from invoked scripts

# Hint: short circuit beginning of pipeline using Fly hijack
# and run DEBUGGING_HINT_CMD below:
export DEBUGGING_HINT_CMD="scripts-resource/scripts/cf/push.sh"

# Script is used for credhub default prefix utility function
# https://github.com/koalaman/shellcheck/wiki/SC1090
# shellcheck source=common-lib.bash
source ${BASE_TEMPLATE_DIR}/common-lib.bash
set_verbose_mode_as_requested_in_secrets

#osb-reverse-proxy specifics
export REPO_NAME=osb-reverse-proxy
export JAR_ARTEFACT_BASE_NAME=osb-reverse-proxy
export RELEASE_VERSION=0.1.0

# credhub password for the spring security potentially granting access to actuators endpoints
# In order to support multiple symlinked osb-reverse-proxy cf apps with distinct passwords
# we need to have per deployment credhub key
function generate_credhub_var_osb_password_request() {
   local CREDHUB_KEY
   CREDHUB_KEY="$(default_credhub_interpolate_prefix)/broker-password"
   local CREDHUB_CREDENTIAL_REQUEST_FILE="${BASE_TEMPLATE_DIR}/credhub-var-broker-password.json"
   cat > ${CREDHUB_CREDENTIAL_REQUEST_FILE} <<EOF
        {
          "name": "${CREDHUB_KEY}",
          "type": "password"
        }
EOF
    echo "Wrote credhub credential request at ${CREDHUB_CREDENTIAL_REQUEST_FILE} with content:"
    cat ${CREDHUB_CREDENTIAL_REQUEST_FILE}
}
generate_credhub_var_osb_password_request
# credhub password for the spring security potentially granting access to actuators endpoints
# In order to support multiple symlinked osb-reverse-proxy cf apps with distinct passwords
# we need to have per deployment credhub key
function generate_credhub_var_service_provider_password_request() {
   local CREDHUB_KEY
   CREDHUB_KEY="$(default_credhub_interpolate_prefix)/service-provider-password"
   local CREDHUB_CREDENTIAL_REQUEST_FILE="${BASE_TEMPLATE_DIR}/credhub-var-service-provider-password.json"
   cat > ${CREDHUB_CREDENTIAL_REQUEST_FILE} <<EOF
        {
          "name": "${CREDHUB_KEY}",
          "type": "password"
        }
EOF
    echo "Wrote credhub credential request at ${CREDHUB_CREDENTIAL_REQUEST_FILE} with content:"
    cat ${CREDHUB_CREDENTIAL_REQUEST_FILE}
}
generate_credhub_var_service_provider_password_request


#Download osb-reverse-proxy.jar, generate credhub variable
${BASE_TEMPLATE_DIR}/common-pre-cf-push.sh

#Replace application-cloud.yml from jar with content specified in secrets.yml
# The cloud profile is enabled by the java buildpack
# As a result, springboot will override application.yml properties from ones found in application-cloud.yml
#May be improved in the future by:
# - specifying the whole content in properties provided as env vars

#Assuming bosh-cli was installed by common-pre-cf-push.sh
APPLICATION_YML=$(bosh int "${SECRETS_DIR}/secrets/meta.yml" --path /meta/osb-reverse-proxy/application_yml)
mkdir -p BOOT-INF/classes
# https://stackoverflow.com/a/49418406/1484823
printf "%s" "${APPLICATION_YML}" > BOOT-INF/classes/application-cloud.yml

apk add zip
zip -r  ${GENERATE_DIR}/${JAR_ARTEFACT_BASE_NAME}.jar BOOT-INF/classes/application-cloud.yml
#check replacement was correctly done
unzip -l ${GENERATE_DIR}/${JAR_ARTEFACT_BASE_NAME}.jar BOOT-INF/classes/application-cloud.yml
echo "broker configured with application-cloud.yml content:"
ls -al BOOT-INF/classes/application-cloud.yml
cat BOOT-INF/classes/application-cloud.yml

# COA exported variables
#    CF_USERNAME=redacted_username
#    CF_ORG=system_domain
#    CF_PASSWORD=
#    CF_API_URL=
#    CF_SPACE=osb-reverse-proxy
#    CF_MANIFEST=generated-files/osb-reverse-proxy_manifest.yml
echo "creating CF pre-requisite"
cf t -o "${CF_ORG}"
cf create-space "${CF_SPACE}" #exit status is zero if space already exists

cf t -o "${CF_ORG}" -s "${CF_SPACE}"

echo "Note: we're unbinding o-intranet-proxy-access-service to refresh ASG when FQDN ip change such as K8S switch (please ignore unbind error output on 1st pipeline exec)."
! cf unbind-service $(extract_deployment_name) o-intranet-proxy-access-service

cf create-service o-intranet-proxy-access default o-intranet-proxy-access-service
