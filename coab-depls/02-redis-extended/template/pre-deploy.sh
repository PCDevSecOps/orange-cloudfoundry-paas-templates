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

#--- Retrieve deployment name
printf "%bRetrieve deployment name...%b\n" "${YELLOW}" "${STD}"
DEPLOYMENT=`basename ${SECRETS_DIR}`
echo "deployment : ${DEPLOYMENT}"

# retrieve and display plan_if from coab-vars.yml
DEPLOYMENT_NAME=$(bosh int "${GENERATE_DIR}/coab-vars.yml" --path /deployment_name)
NORMALIZED_DEPLOYMENT_NAME=$(grep deployment_name  "${GENERATE_DIR}/coab-vars.yml" | awk -F ":" '{gsub("_","-",$2);print $2}')
echo "deployment-name: $NORMALIZED_DEPLOYMENT_NAME" >> ${GENERATE_DIR}/coab-vars.yml
cat ${GENERATE_DIR}/coab-vars.yml