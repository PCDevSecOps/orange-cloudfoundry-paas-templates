#!/bin/sh -e
#===========================================================================
# This hook script aims to :
# Import shield configuration
# Create uaa client for dedicated shield (using cf-uaac cli)
# Init and unlock the shield webui (using shield cli)
#===========================================================================

GENERATE_DIR=${GENERATE_DIR:-.}
BASE_TEMPLATE_DIR=${BASE_TEMPLATE_DIR:-template}
SECRETS_DIR=${SECRETS_DIR:-.}

echo "use and generate file at $GENERATE_DIR"
echo "use template dir: <$BASE_TEMPLATE_DIR>  and secrets dir: <$SECRETS_DIR>"

####### end common header ######

#--- Parameters
BOSH_CLI_VERSION="3.0.1"
CREDHUB_CLI_VERSION="1.7.5"
UAA_CLI_VERSION="4.1.0"
SHIELD_CLI_VERSION="8.0.17"

UAA_ADMIN_PASSWORD_PATH="/bosh-master/cf/uaa_admin_client_secret"  # credential_leak_validated
ADMIN_PASSWORD_PATH="/bosh-master/bosh-coab/admin_password"
SYSTEM_DOMAIN_PATH="/secrets/cloudfoundry_system_domain"
OPS_DOMAIN_PATH="/secrets/cloudfoundry_ops_domain"
ROOT_DIR=$(pwd)
STATUS_FILE="/tmp/$$.res"
SHARED_SECRETS="${ROOT_DIR}/credentials-resource/shared/secrets.yml"
INTERNAL_CA_CERT="${ROOT_DIR}/credentials-resource/shared/certs/internal_paas-ca/server-ca.crt"

#--- Colors and styles
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'

#--- Install bosh cli
printf "%bInstall bosh cli \"${BOSH_CLI_VERSION}\"...%b\n" "${YELLOW}" "${STD}"
curl "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSH_CLI_VERSION}-linux-amd64" -L -s -o /usr/local/bin/bosh
if [ $? != 0 ] ; then
	printf "\n%bERROR: Install bosh cli failed%b\n\n" "${RED}" "${STD}" ; exit 0
fi
chmod 755 /usr/local/bin/bosh

#--- Install credhub cli
printf "%bInstall credhub cli \"${CREDHUB_CLI_VERSION}\"...%b\n" "${YELLOW}" "${STD}"
(curl "https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_CLI_VERSION}/credhub-linux-${CREDHUB_CLI_VERSION}.tgz" -L -s | tar -xz -C /usr/local/bin ; echo $? > ${STATUS_FILE})
result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
if [ ${result} != 0 ] ; then
  printf "\n%bERROR: Install credhub cli failed%b\n\n" "${RED}" "${STD}" ; exit 0
fi
chmod 755 /usr/local/bin/credhub

#--- Install ruby SDK
printf "%bInstall latest ruby sdk...%b\n" "${YELLOW}" "${STD}"
apk add --update alpine-sdk

#--- Install uaa cli
printf "%bInstall uaa cli \"${UAA_CLI_VERSION}\"...%b\n" "${YELLOW}" "${STD}"
gem install cf-uaac --no-document -v ${UAA_CLI_VERSION}

#--- Install shield cli
curl "https://github.com/starkandwayne/shield/releases/download/v${SHIELD_CLI_VERSION}/shield-linux-amd64" -L -s -o /usr/local/bin/shield
if [ $? != 0 ] ; then
	printf "\n%bERROR: Install shield cli failed%b\n\n" "${RED}" "${STD}" ; exit 0
fi
chmod 755 /usr/local/bin/shield

#--- Log to credhub
printf "%bLog to credhub...%b\n" "${YELLOW}" "${STD}"
export CREDHUB_SERVER="https://credhub.internal.paas:8844"
export CREDHUB_CLIENT="director_to_credhub"
export CREDHUB_CA_CERT="${INTERNAL_CA_CERT}"
export CREDHUB_SECRET=$(bosh int ${SHARED_SECRETS} --path /secrets/bosh_credhub_secrets)
credhub api > /dev/null 2>&1
credhub login > /dev/null 2>&1
if [ $? = 1 ] ; then
  printf "\n%bLog to credhub failed.%b\n\n" "${RED}" "${STD}" ; exit 0
fi

#--- Retrieve deployment name
printf "%bRetrieve deployment name...%b\n" "${YELLOW}" "${STD}"
DEPLOYMENT=`basename ${SECRETS_DIR}`
echo "deployment : ${DEPLOYMENT}"

#--- Log to bosh director
printf "%bLog to bosh director...%b\n" "${YELLOW}" "${STD}"
export BOSH_CLIENT="admin"
export BOSH_CLIENT_SECRET="$(credhub g -n ${ADMIN_PASSWORD_PATH} | grep 'value:' | awk '{print $2}')"
export BOSH_CA_CERT="${INTERNAL_CA_CERT}"
export BOSH_ENVIRONMENT="192.168.99.155"
bosh alias-env bosh > /dev/null 2>&1
bosh -n log-in
if [ $? != 0 ] ; then
  printf "\n%bLog to bosh director failed%b\n\n" "${RED}" "${STD}" ; exit 0
fi

#--- Run import errand shield (see https://github.com/orange-cloudfoundry/paas-templates/issues/293)
printf "%bImport shield jobs...%b\n" "${YELLOW}" "${STD}"
bosh -d ${DEPLOYMENT} run-errand import --instance=shield
boshInstances=$(bosh -d ${DEPLOYMENT} instances | grep "running" | grep "rmq" | awk '{print $1}')
for instance in ${boshInstances} ; do
  bosh -d ${DEPLOYMENT} run-errand import --instance=${instance}
done


#--- Log to UAA and add UAA Shield client
printf "%bLog to uaa...%b\n" "${YELLOW}" "${STD}"
export UAA_CLIENT="admin"
export UAA_CLIENT_SECRET="$(credhub g -n ${UAA_ADMIN_PASSWORD_PATH} | grep 'value:' | awk '{print $2}')"
UAA_DEPLOYMENT_CLIENT_SECRET_PATH="/bosh-coab/${DEPLOYMENT}/shield-webui-uaa-client-secret"
export UAA_DEPLOYMENT_CLIENT_SECRET="$(credhub g -n ${UAA_DEPLOYMENT_CLIENT_SECRET_PATH} | grep 'value:' | awk '{print $2}')"

export SYSTEM_DOMAIN="$(credhub g -n ${SYSTEM_DOMAIN_PATH} | grep 'value:' | awk '{print $2}')"
UAA_TARGET="https://login.${SYSTEM_DOMAIN}"
uaac target ${UAA_TARGET} --skip-ssl-validation
uaac token client get ${UAA_CLIENT} -s ${UAA_CLIENT_SECRET}

#uaac clients
count=$(uaac client get "shield-webui-${DEPLOYMENT}-client" | grep "name: shield-webui-${DEPLOYMENT}-client" | wc -l)
if [ ${count} = 1 ] ; then
  uaac client delete shield-webui-${DEPLOYMENT}-client
fi
uaac client add shield-webui-${DEPLOYMENT}-client \
    --scope openid \
    --authorities uaa.none \
    --authorized_grant_types authorization_code \
    --redirect_uri https://shield-webui-${DEPLOYMENT}.${SYSTEM_DOMAIN}/auth/cf/redir \
    --access_token_validity 180 \
    --refresh_token_validity 180 \
    --secret ${UAA_DEPLOYMENT_CLIENT_SECRET}

#shield init and unlock (needs to set no_proxy in order to prevent internet-proxy from recursing towards google DNS)
printf "%bShield activation...%b\n" "${YELLOW}" "${STD}"
export OPS_DOMAIN="$(credhub g -n ${OPS_DOMAIN_PATH} | grep 'value:' | awk '{print $2}')"
export SHIELD_CORE=sandbox
shield
export no_proxy=$no_proxy,shield-webui-${DEPLOYMENT}.${OPS_DOMAIN}
shield api -k https://shield-webui-${DEPLOYMENT}.${OPS_DOMAIN} ${SHIELD_CORE}
set +o errexit
printf "%bShield init...%b\n" "${YELLOW}" "${STD}"
shield --core ${SHIELD_CORE} init --master shield
set -o errexit
printf "%bShield unlock...%b\n" "${YELLOW}" "${STD}"
shield --core ${SHIELD_CORE} unlock --master shield