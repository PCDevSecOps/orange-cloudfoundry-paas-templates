#!/bin/sh -e
#===========================================================================
# This hook script aims to :
#===========================================================================

GENERATE_DIR=${GENERATE_DIR:-.}
BASE_TEMPLATE_DIR=${BASE_TEMPLATE_DIR:-template}
SECRETS_DIR=${SECRETS_DIR:-.}

echo "use and generate file at $GENERATE_DIR"
echo "use template dir: <$BASE_TEMPLATE_DIR>  and secrets dir: <$SECRETS_DIR>"

# generate fake coab vars file if brokered_service_instance_guid not present in coab-vars.yml
${CUSTOM_SCRIPT_DIR}/generate-fake-coab-vars-when-vars-are-missing.bash

# proxy instance group needs to reference redis master nodes dynamically (ips are allocated by bosh)
# for that, we use bosh dns notation : q-s0-<az>.<instance group>.<network>.<deployment name>.bosh
# coab will affect a deployment name s_guid but bosh dns will resolve it in s-guid
# that's why we must normalize the deployment name and use the normalized deployment name value in manifest/operators
# coab-vars.yml -> deployment_name (s_guid) -> deployment-name (s-guid) -> fake-vars.yml
NORMALIZED_DEPLOYMENT_NAME=$(grep deployment_name  "${GENERATE_DIR}/coab-vars.yml" | awk -F ":" '{gsub("_","-",$2);print $2}')
echo "deployment-name: $NORMALIZED_DEPLOYMENT_NAME" > ${GENERATE_DIR}/fake-vars.yml
cat ${GENERATE_DIR}/fake-vars.yml

# necessary for coab to track deployment completion in resulting manifest
# shellcheck disable=SC2086
${CUSTOM_SCRIPT_DIR}/prepare-coab-completion-marker.bash

# shellcheck disable=SC2086
COA_HOOKS_DIR=${CUSTOM_SCRIPT_DIR}/../../../shared-operators/coab/coa-hooks/
${COA_HOOKS_DIR}/extract-x-osb-cmdb-params-for-coab.bash