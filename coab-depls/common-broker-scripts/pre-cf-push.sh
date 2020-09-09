#!/bin/bash

# Hint: short circuit beginning of pipeline using Fly hijack
# and run DEBUGGING_HINT_CMD below:
export DEBUGGING_HINT_CMD="scripts-resource/scripts/cf/push.sh"


#echo "CUSTOM_SCRIPT_DIR is ${CUSTOM_SCRIPT_DIR}" # expecting templates-resource/ops-depls/cf-apps-deployments/osb-cmdb-broker/template
script="${CUSTOM_SCRIPT_DIR}/../../../../coab-depls/common-broker-scripts/common-lib.bash"
# https://github.com/koalaman/shellcheck/wiki/SC1090
# shellcheck source=common-lib.bash
source "${script}"
set_verbose_mode_as_requested_in_secrets

# Expecting credhub file such as to trigger credhub interpolation
# echo '{"name": "/secrets/cloudfoundry_service_brokers_osbcmdb_password","type": "password"}' > $CUSTOM_SCRIPT_DIR/credhub-var-osb-cmdb-pwd.json

INTERPOLATE_CREDHUB_MANIFEST=${INTERPOLATE_CREDHUB_MANIFEST:false}
if [[ -n $(credhub_var_files) || ${INTERPOLATE_CREDHUB_MANIFEST} == "true" ]];
then
    install_credhub_cli
    credhub_login
    credhub_declare_variables
    credhub_interpolate_manifest
fi

BINARY_MODE=$(fetch_deployment_secret_prop "mode" "release")
TARBALL_BRANCH=$(fetch_deployment_secret_prop "tarball_branch" "develop")

REPO_NAME=${REPO_NAME:-cf-ops-automation-broker}
JAR_ARTEFACT_BASE_NAME=${JAR_ARTEFACT_BASE_NAME:-cf-ops-automation-bosh-broker}
JAR_ARTEFACT_NAME=${JAR_ARTEFACT_NAME:-${JAR_ARTEFACT_BASE_NAME}.jar}
if [[ "$BINARY_MODE" == "tarball" ]]
then
    echo "Assuming development/integration mode, and opting to deploy latest tarball from branch ${TARBALL_BRANCH} (instead of the current release number : ${RELEASE_VERSION})"
    #Enable the following line to deploy the latest tarball
    #See bash regexp support in http://www.tldp.org/LDP/abs/html/abs-guide.html#REGEXMATCHREF
    URL=$(curl "https://circleci.com/api/v1.1/project/github/orange-cloudfoundry/${REPO_NAME}/latest/artifacts?filter=successful&branch=${TARBALL_BRANCH}" | grep -o 'https://[^"]*' | grep ${JAR_ARTEFACT_BASE_NAME})
else
    RELEASE_VERSION=${RELEASE_VERSION:-0.30.0}
    echo "Deploying coab broker version ${RELEASE_VERSION}"
    URL=https://github.com/orange-cloudfoundry/${REPO_NAME}/releases/download/v${RELEASE_VERSION}/${JAR_ARTEFACT_BASE_NAME}-${RELEASE_VERSION}.jar
fi

echo "Downloading artefact from ${URL}"
curl ${URL} -L -s -o ${GENERATE_DIR}/${JAR_ARTEFACT_NAME}

ls -al ${GENERATE_DIR}/${JAR_ARTEFACT_NAME}

echo "Details on artefact build last commit:"
#Display build date
#unzip -l -q ${GENERATE_DIR}/cf-ops-automation-coa-bosh-broker.jar META-INF/MANIFEST.MF
#jar tvf ${GENERATE_DIR}/cf-ops-automation-coa-bosh-broker.jar | grep META-INF/MANIFEST.MF

#Display GIT version recorded into manifest content if any
#Otherwise just display a message
unzip -q -c ${GENERATE_DIR}/${JAR_ARTEFACT_NAME} META-INF/MANIFEST.MF | grep SCM-Revision -A3 || echo "No Scm metadata in jar"

cat << EOF
#Reminder on SCM-Revision format for git.commit.id.describe
# eg. v0.26.0-11-gaac8d2f
#       ^     ^  ^        ^
#       |     |  |        \-- if a dirtyMarker was given, it will appear here if the repository is in "dirty" state (i.e. uncommited local changes)
#       |     |  \---------- the "g" prefixed commit id. The prefix is compatible with what git-describe would return - weird, but true.
#       |     \------------- the number of commits away from the found tag. So "aac8d2f" is 11 commits ahead of "v0.26.0", in this example.
#       \----------------- the "nearest" tag, to the mentioned commit. (0.26.0)
# More into https://github.com/ktoso/maven-git-commit-id-plugin#git-describe---short-intro-to-an-awesome-command
EOF


