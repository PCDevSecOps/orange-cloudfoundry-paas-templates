#!/bin/sh

#set -o xtrace # debug mode
set -o errexit # exit on errors

# Setup configurations
# bosh cli version install
bosh_cli_version="2.0.36"
curl -L -s -o /usr/local/bin/bosh "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${bosh_cli_version}-linux-amd64"
chmod 755 /usr/local/bin/bosh

# Setup environment
SECRETS_DIR=${SECRETS_DIR:-.}
SANDBOX_ORG=$(bosh int "${SECRETS_DIR}/secrets/secrets.yml" --path /secrets/sandbox-service/cf/org)
SANDBOX_USER=$(bosh int "${SECRETS_DIR}/secrets/secrets.yml" --path /secrets/sandbox-service/cf/user)
SANDBOX_PASSWORD=$(bosh int "${SECRETS_DIR}/secrets/secrets.yml" --path /secrets/sandbox-service/cf/password)

SB_UI_VERSION=1.0.13
SB_UI_GITHUB_BRANCH=master
#SB_UI_URL=https://jcenter.bintray.com/com/orange/clara/cloud/ui/sandbox/elpaaso-sandbox-ui/${SB_UI_VERSION}/:elpaaso-sandbox-ui-${SB_UI_VERSION}.jar
SB_UI_URL=https://bintray.com/artifact/download/elpaaso/maven/com/orange/clara/cloud/ui/sandbox/elpaaso-sandbox-ui/${SB_UI_VERSION}/elpaaso-sandbox-ui-${SB_UI_VERSION}.jar

SB_SERVICE_VERSION=1.0.36
#SB_SERVICE_URL=https://bintray.com/artifact/download/elpaaso/maven/com/orange/clara/cloud/service/sandbox/elpaaso-sandbox-service/${SB_SERVICE_VERSION}/elpaaso-sandbox-service-${SB_SERVICE_VERSION}.jar
SB_SERVICE_URL=https://oss.jfrog.org/artifactory/oss-release-local/com/orange/clara/cloud/services/sandbox/elpaaso-sandbox-service/${SB_SERVICE_VERSION}/elpaaso-sandbox-service-${SB_SERVICE_VERSION}.jar

echo "downloading Sandbox service binary"
curl -L -s  ${SB_SERVICE_URL} -o ${GENERATE_DIR}/elpaaso-sandbox-service.jar

echo "downloading Sandbox ui binary"
curl -L -s ${SB_UI_URL} -o ${GENERATE_DIR}/elpaaso-sandbox-ui.jar


# Pre requisites
cf create-user "$SANDBOX_USER" "$SANDBOX_PASSWORD"
cf set-org-role  "$SANDBOX_USER"  "$SANDBOX_ORG" OrgManager
cf create-space default-space -o "$SANDBOX_ORG"

cf create-space "$CF_SPACE" -o "$CF_ORG"
cf target -s "$CF_SPACE" -o "$CF_ORG"
