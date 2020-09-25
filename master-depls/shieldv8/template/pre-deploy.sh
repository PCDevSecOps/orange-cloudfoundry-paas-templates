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

# generate operators from template
TENANTS="master|micro"
for tenant in $(echo ${TENANTS} | tr "|" " "); do
    echo ${tenant}
    DEPLOYMENTS=$(bosh int "${GENERATE_DIR}/custom-shieldv8-vars.yml" --path /bbr-${tenant}-depls-config)
    echo ${DEPLOYMENTS}
    for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
        echo ${deployment}
        cp ${GENERATE_DIR}/09-add-shield-import-system-bbr-deployment-${tenant}-depls-errand-operators.yml ${GENERATE_DIR}/09-add-shield-import-system-bbr-deployment-${tenant}-${deployment}-errand-operators.yml
        sed -i -e "s/#deployment#/${deployment}/g" ${GENERATE_DIR}/09-add-shield-import-system-bbr-deployment-${tenant}-${deployment}-errand-operators.yml
        sed -i -e "s/storage: local-bbr-cfcr-(ip)/storage: local-bbr-${deployment}-${tenant}-(ip)/g" ${GENERATE_DIR}/09-add-shield-import-system-bbr-deployment-${tenant}-${deployment}-errand-operators.yml
        sed -i -e "s/bucket: ((s3_bucket_prefix))-cfcr/bucket: ((s3_bucket_prefix))-${deployment}-${tenant}/g" ${GENERATE_DIR}/09-add-shield-import-system-bbr-deployment-${tenant}-${deployment}-errand-operators.yml
        sed -i -e "s/name: local-bbr-cfcr-(ip)/name: local-bbr-${deployment}-${tenant}-(ip)/g" ${GENERATE_DIR}/09-add-shield-import-system-bbr-deployment-${tenant}-${deployment}-errand-operators.yml
    done
    rm ${GENERATE_DIR}/09-add-shield-import-system-bbr-deployment-${tenant}-depls-errand-operators.yml
done


####### end treatment ######