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

####### end setup configuration ######

# retrieve and display plan_if from coab-vars.yml
PLAN_ID=$(bosh int "${GENERATE_DIR}/coab-vars.yml" --path /plan_id)
echo $PLAN_ID

#search for disabled vars matching plan_if
#if found copy it from TEMPLATE_DIR to GENERATE_DIR with the COA naming convention
for j in `find $BASE_TEMPLATE_DIR -name "cf-mysql-extended-vars*.yml" | awk -F "vars_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
    if [ $PLAN_ID = $j ] ; then
        echo "copy from $BASE_TEMPLATE_DIR/cf-mysql-extended-vars_$j.yml to $GENERATE_DIR/cf-mysql-extended-vars.yml"
        cp $BASE_TEMPLATE_DIR/cf-mysql-extended-vars_$j.yml $GENERATE_DIR/cf-mysql-extended-vars.yml
    fi
done

# generate fake coab vars file if brokered_service_instance_guid not present in coab-vars.yml
INSTANCE_ID=$(bosh int "${GENERATE_DIR}/coab-vars.yml" --path /instance_id)
echo "INSTANCE_ID is:${INSTANCE_ID}"
set +e # prevent from exiting in case of grep failure (because fake-coab-vars.yml generation is triggered on grep failure)
grep brokered_service_instance_guid ${BASE_TEMPLATE_DIR}/coab-vars.yml
if [ $? != 0 ] ; then
    echo "brokered_service_instance_guid is missing from coab-vars.yml"
    echo "generating fake-coab-vars.yml in ${GENERATE_DIR} to complete it for coab smoke tests not fronted by osb-cmdb"
    cat << EOF > ${GENERATE_DIR}/fake-coab-vars.yml
    parameters:
      x-osb-cmdb:
        labels:
          brokered_service_instance_guid: ${INSTANCE_ID}
          brokered_service_context_organization_guid: "faked_organization_guid_in_pre_deploy_sh"
          brokered_service_context_space_guid: "faked_space_guid_in_pre_deploy_sh"
EOF
    cat ${GENERATE_DIR}/fake-coab-vars.yml
fi
set -e

# necessary for coab to track deployment completion in resulting manifest
# shellcheck disable=SC2086
${CUSTOM_SCRIPT_DIR}/prepare-coab-completion-marker.bash