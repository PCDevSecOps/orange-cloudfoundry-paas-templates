#!/bin/sh -e
#===========================================================================
# This hook script aims to :
# Create prefix in the bucket for dedicated shield (using mc cli)
# Select the matching plan defined in coab-vars.yml file
#===========================================================================

GENERATE_DIR=${GENERATE_DIR:-.}
BASE_TEMPLATE_DIR=${BASE_TEMPLATE_DIR:-template}
SECRETS_DIR=${SECRETS_DIR:-.}

echo "use and generate file at $GENERATE_DIR"
echo "use template dir: <$BASE_TEMPLATE_DIR>  and secrets dir: <$SECRETS_DIR>"

####### end common header ######

#--- Parameters
BOSH_CLI_VERSION="3.0.1"

ROOT_DIR=$(pwd)
STATUS_FILE="/tmp/$$.res"
SHARED_SECRETS="${ROOT_DIR}/credentials-resource/shared/secrets.yml"
INTERNAL_CA_CERT="${ROOT_DIR}/credentials-resource/shared/certs/internal_paas-ca/server-ca.crt"

#--- Colors and styles
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'

#--- Install curl
printf "\n%bInstall curl tool...%b\n" "${YELLOW}" "${STD}"
apk add --update
apk add --no-cache --no-progress curl
if [ $? != 0 ] ; then
	printf "\n%bERROR: Install curl failed.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Install bosh cli
printf "%bInstall bosh cli \"${BOSH_CLI_VERSION}\"...%b\n" "${YELLOW}" "${STD}"
curl "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSH_CLI_VERSION}-linux-amd64" -L -s -o /usr/local/bin/bosh
if [ $? != 0 ] ; then
	printf "\n%bERROR: Install bosh cli failed%b\n\n" "${RED}" "${STD}" ; exit 0
fi
chmod 755 /usr/local/bin/bosh

#--- Install minio
printf "%bInstall minio cli ...%b\n" "${YELLOW}" "${STD}"
rm -f mc
(curl "https://dl.minio.io/client/mc/release/linux-amd64/mc" -L -s -o /usr/local/bin/mc 2>&1 ; echo $? > ${STATUS_FILE})
result=`cat ${STATUS_FILE}` ; rm -f ${STATUS_FILE}
if [ ${result} != 0 ] ; then
  display "ERROR" "Install minio failed"
fi
chmod 755 /usr/local/bin/mc

HOST_PATH="/secrets/shield/s3_host"
export HOST="$(bosh int ${SHARED_SECRETS} --path ${HOST_PATH})"

ACCESS_KEY_ID_PATH="/secrets/shield/s3_access_key_id"
export ACCESS_KEY_ID="$(bosh int ${SHARED_SECRETS} --path ${ACCESS_KEY_ID_PATH})"

ACCESS_KEY_SECRET_PATH="/secrets/shield/s3_secret_access_key"
export ACCESS_KEY_SECRET="$(bosh int ${SHARED_SECRETS} --path ${ACCESS_KEY_SECRET_PATH})"

PREFIX_PATH="/secrets/shield/s3_bucket_prefix"
export PREFIX="$(bosh int ${SHARED_SECRETS} --path ${PREFIX_PATH})"

#--- Retrieve deployment name
printf "%bRetrieve deployment name...%b\n" "${YELLOW}" "${STD}"
DEPLOYMENT=`basename ${SECRETS_DIR}`
echo "deployment : ${DEPLOYMENT}"

#--- Connect to OBOS S3
set +o errexit
BUCKET=${PREFIX}-cf-mysqlcoab
mc config host add obos https://${HOST}:443 ${ACCESS_KEY_ID} ${ACCESS_KEY_SECRET} --api S3v4
if [ $? != 0 ] ; then
  printf "\n%bERROR : OBOS access failed.%b\n\n" "${RED}" "${STD}"
else
  #--- Create buckets (or assert if they already exists)
  mc mb obos/${BUCKET}/${DEPLOYMENT}/ --insecure --ignore-existing
fi
set -o errexit

####### end setup configuration ######

# retrieve and display plan_if from coab-vars.yml
PLAN_ID=$(bosh int "${GENERATE_DIR}/coab-vars.yml" --path /plan_id)
echo $PLAN_ID

#search for disabled operators matching plan_if
#if found copy it from TEMPLATE_DIR to GENERATE_DIR with the COA naming convention
#for j in `find $BASE_TEMPLATE_DIR -name "plan-operators*.yml" | awk -F "_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
#    if [ $PLAN_ID = $j ] ; then
#        echo "copy from $BASE_TEMPLATE_DIR/plan-operators_$j.yml to $GENERATE_DIR/plan-operators.yml"
#        cp $BASE_TEMPLATE_DIR/plan-operators_$j.yml $GENERATE_DIR/plan-operators.yml
#    fi
#done

#search for disabled vars matching plan_if
#if found copy it from TEMPLATE_DIR to GENERATE_DIR with the COA naming convention
for j in `find $BASE_TEMPLATE_DIR -name "cf-mysql-vars*.yml" | awk -F "vars_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
    if [ $PLAN_ID = $j ] ; then
        echo "copy from $BASE_TEMPLATE_DIR/cf-mysql-vars_$j.yml to $GENERATE_DIR/cf-mysql-vars.yml"
        cp $BASE_TEMPLATE_DIR/cf-mysql-vars_$j.yml $GENERATE_DIR/cf-mysql-vars.yml
    fi
done

####### end treatment ######