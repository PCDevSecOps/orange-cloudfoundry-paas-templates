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

#--- Colors and styles
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'

# retrieve and display plan_if from coab-vars.yml
PLAN_ID=$(bosh int "${GENERATE_DIR}/coab-vars.yml" --path /plan_id)
echo $PLAN_ID

#search for disabled vars matching plan_if
#if found copy it from TEMPLATE_DIR to GENERATE_DIR with the COA naming convention
for j in `find $BASE_TEMPLATE_DIR -name "mongodb-vars*.yml" | awk -F "vars_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
    if [ $PLAN_ID = $j ] ; then
        echo "copy from $BASE_TEMPLATE_DIR/mongodb-vars_$j.yml to $GENERATE_DIR/mongodb-vars.yml"
        cp $BASE_TEMPLATE_DIR/mongodb-vars_$j.yml $GENERATE_DIR/mongodb-vars.yml
    fi
done

# added for bosh-metric hack
# for that, we use bosh dns notation : q-s0-<az>.<instance group>.<network>.<deployment name>.bosh
# coab will affect a deployment name s_guid but bosh dns will resolve it in s-guid
# that's why we must normalize the deployment name and use the normalized deployment name value in manifest/operators
# coab-vars.yml -> deployment_name (s_guid) -> deployment-name (s-guid) -> fake-vars.yml
NORMALIZED_DEPLOYMENT_NAME=$(grep deployment_name  "${GENERATE_DIR}/coab-vars.yml" | awk -F ":" '{gsub("_","-",$2);print $2}')
echo "deployment-name: $NORMALIZED_DEPLOYMENT_NAME" > ${GENERATE_DIR}/fake-vars.yml
cat ${GENERATE_DIR}/fake-vars.yml

# generate fake coab vars file if brokered_service_instance_guid not present in coab-vars.yml
${CUSTOM_SCRIPT_DIR}/generate-fake-coab-vars-when-vars-are-missing.bash

# necessary for coab to track deployment completion in resulting manifest
# shellcheck disable=SC2086
${CUSTOM_SCRIPT_DIR}/prepare-coab-completion-marker.bash

# shellcheck disable=SC2086
COA_HOOKS_DIR=${CUSTOM_SCRIPT_DIR}/../../../shared-operators/coab/coa-hooks/
${COA_HOOKS_DIR}/extract-x-osb-cmdb-params-for-coab.bash

####### end treatment ######
