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

# generate fake coab vars file if brokered_service_instance_guid not present in coab-vars.yml
${CUSTOM_SCRIPT_DIR}/generate-fake-coab-vars-when-vars-are-missing.bash

# necessary for coab to track deployment completion in resulting manifest
# shellcheck disable=SC2086
${CUSTOM_SCRIPT_DIR}/prepare-coab-completion-marker.bash

# shellcheck disable=SC2086
COA_HOOKS_DIR=${CUSTOM_SCRIPT_DIR}/../../../shared-operators/coab/coa-hooks/
${COA_HOOKS_DIR}/extract-x-osb-cmdb-params-for-coab.bash

####### end common header ######