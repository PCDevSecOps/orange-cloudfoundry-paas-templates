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

ROOT_DIR=$(pwd)
STATUS_FILE="/tmp/$$.res"
SHARED_SECRETS="${ROOT_DIR}/credentials-resource/shared/secrets.yml"
INTERNAL_CA_CERT="${ROOT_DIR}/credentials-resource/shared/certs/internal_paas-ca/server-ca.crt"

#--- Colors and styles
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'

#--- Install minio
printf "%bInstall minio cli ...%b\n" "${YELLOW}" "${STD}"
rm -f mc
(curl "https://dl.minio.io/client/mc/release/linux-amd64/mc" -L -s -o /usr/local/bin/mc 2>&1 ; echo $? > ${STATUS_FILE})
result=`cat ${STATUS_FILE}` ; rm -f ${STATUS_FILE}
if [ ${result} != 0 ] ; then
  display "ERROR" "Install minio failed"
fi
chmod 755 /usr/local/bin/mc

HOST_PATH="/secrets/backup/remote_s3/host"
export HOST="$(bosh int ${SHARED_SECRETS} --path ${HOST_PATH})"

ACCESS_KEY_ID_PATH="/secrets/backup/remote_s3/access_key_id"
export ACCESS_KEY_ID="$(bosh int ${SHARED_SECRETS} --path ${ACCESS_KEY_ID_PATH})"

ACCESS_KEY_SECRET_PATH="/secrets/backup/remote_s3/secret_access_key"
export ACCESS_KEY_SECRET="$(bosh int ${SHARED_SECRETS} --path ${ACCESS_KEY_SECRET_PATH})"

PREFIX_PATH="/secrets/backup/bucket_prefix"
export PREFIX="$(bosh int ${SHARED_SECRETS} --path ${PREFIX_PATH})"

#--- Retrieve deployment name
printf "%bRetrieve deployment name...%b\n" "${YELLOW}" "${STD}"
DEPLOYMENT=`basename ${SECRETS_DIR}`
echo "deployment : ${DEPLOYMENT}"

#--- Connect to remote S3
set +o errexit
SITE_PATH="/secrets/site"
is_brmc=$(bosh int ${SHARED_SECRETS} --path ${SITE_PATH} | grep "brmc" | wc -l)
if [ ${is_brmc} -eq 1 ] ; then
    echo "set intranet proxy"
    export http_proxy=http://intranet-http-proxy.internal.paas:3129
    export https_proxy=http://intranet-http-proxy.internal.paas:3129
    export no_proxy=localhost,127.0.0.1
fi
BUCKET=${PREFIX}-cassandracoab
mc config host add remote_s3 https://${HOST}:443 ${ACCESS_KEY_ID} ${ACCESS_KEY_SECRET} --api S3v4
if [ $? != 0 ] ; then
  printf "\n%bERROR : S3 access failed.%b\n\n" "${RED}" "${STD}"
else
  #--- Create buckets (or assert if they already exists)
  mc mb remote_s3/${BUCKET} --insecure --ignore-existing
fi
set -o errexit

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
for j in `find $BASE_TEMPLATE_DIR -name "cassandra-vars*.yml" | awk -F "vars_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
    if [ $PLAN_ID = $j ] ; then
        echo "copy from $BASE_TEMPLATE_DIR/cassandra-vars_$j.yml to $GENERATE_DIR/cassandra-vars.yml"
        cp $BASE_TEMPLATE_DIR/cassandra-vars_$j.yml $GENERATE_DIR/cassandra-vars.yml
    fi
done

####### end treatment ######