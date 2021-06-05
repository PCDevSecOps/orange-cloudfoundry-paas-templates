#!/bin/bash
set -o errexit #needed as not inherited from invoked scripts

# Script is used for credhub default prefix utility function
# https://github.com/koalaman/shellcheck/wiki/SC1090
# shellcheck source=common-lib.bash
source ${BASE_TEMPLATE_DIR}/common-lib.bash
# shellcheck source=osb-cmdb-common-lib.bash
source ${BASE_TEMPLATE_DIR}/osb-cmdb-common-lib.bash
set_verbose_mode_as_requested_in_secrets

#osb-cmdb specifics
export REPO_NAME=osb-cmdb
export JAR_ARTEFACT_BASE_NAME=osb-cmdb
export SPACE_QUOTA=osb-cmdb-quota
export RELEASE_VERSION=1.5.1

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

function generate_credhub_var_admin_password_request() {
   BROKER_USER_PASSWORD_CREDHUB_KEY="$(default_credhub_interpolate_prefix)/broker-admin-password"
   CREDHUB_CREDENTIAL_REQUEST_FILE="${BASE_TEMPLATE_DIR}/credhub-var-broker-admin-password.json"
   cat > ${CREDHUB_CREDENTIAL_REQUEST_FILE} <<EOF
        {
          "name": "${BROKER_USER_PASSWORD_CREDHUB_KEY}",
          "type": "password"
        }
EOF
    echo "Wrote credhub credential request at ${CREDHUB_CREDENTIAL_REQUEST_FILE} with content:"
    cat ${CREDHUB_CREDENTIAL_REQUEST_FILE}
}
generate_credhub_var_admin_password_request


#Download osb-cmdb.jar, generate credhub variable
${BASE_TEMPLATE_DIR}/common-pre-cf-push.sh

#Replace application-cloud.yml from jar with content specified in secrets.yml
# The cloud profile is enabled by the java buildpack
# As a result, springboot will override application.yml properties from ones found in application-cloud.yml
#May be improved in the future by:
# - specifying the whole content in properties provided as env vars

#Assuming bosh-cli was installed by common-pre-cf-push.sh
APPLICATION_YML=$(bosh int "${SECRETS_DIR}/secrets/meta.yml" --path /meta/osb-cmdb-broker/application_yml)
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
#    CF_SPACE=osb-cmdb-broker
#    CF_MANIFEST=generated-files/osb-cmdb-broker_manifest.yml
cf t -o ${CF_ORG}
cf create-space $CF_SPACE

function create_backing_services_org_and_space_if_requested() {
    local CREATE_BACKING_SERVICES_ORG BACKING_SERVICE_ORG BACKING_SERVICE_SPACE
    CREATE_BACKING_SERVICES_ORG=$(fetch_deployment_secret_prop "osb-cmdb-broker/create-default-org" "false")
    if [[ ${CREATE_BACKING_SERVICES_ORG} == "true" ]]; then
        BACKING_SERVICE_ORG=$(backing_services_org)
        echo "Creating backing service org ${BACKING_SERVICE_ORG} as requested if necessary"
        cf org ${BACKING_SERVICE_ORG} || cf create-org ${BACKING_SERVICE_ORG}

        BACKING_SERVICE_SPACE=$(backing_services_space)
        echo "Creating backing service space ${BACKING_SERVICE_SPACE} as requested if necessary"
        cf t -o ${BACKING_SERVICE_ORG} &> /tmp/cf-t-output.txt
        cf space ${BACKING_SERVICE_SPACE} || cf create-space ${BACKING_SERVICE_SPACE}
        #Restore target
        cf t -o ${CF_ORG} &> /tmp/cf-t-output.txt
    fi
}

create_backing_services_org_and_space_if_requested
