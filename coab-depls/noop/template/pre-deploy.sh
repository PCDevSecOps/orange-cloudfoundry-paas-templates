#!/bin/bash

set -o errexit    # exit on errors
export DEBUGGING_HINT_CMD="scripts-resource/concourse/tasks/pre_deploy/run.sh"

GENERATE_DIR=${GENERATE_DIR:-.}
CUSTOM_SCRIPT_DIR=${CUSTOM_SCRIPT_DIR:-template-resource}
SECRETS_DIR=${SECRETS_DIR:-.}

echo "use and generate file at $GENERATE_DIR"
echo "use template dir: <$CUSTOM_SCRIPT_DIR>  and secrets dir: <$SECRETS_DIR>"

# necessary for coab to track deployment completion in resulting manifest
# shellcheck disable=SC2086
${CUSTOM_SCRIPT_DIR}/prepare-coab-completion-marker.bash

# Version with symlink in coab instances adds extra work on coab to copy the symlink in each service instance directory.
# Instead we directly pointing to shared_operators avoids this user-facing overhead
#CUSTOM_SCRIPT_DIR expected at ../paas-templates/coab-depls/noop/template
COA_HOOKS_DIR=${CUSTOM_SCRIPT_DIR}/../../../shared-operators/coab/coa-hooks/

# shellcheck disable=SC2086
${COA_HOOKS_DIR}/extract-x-osb-cmdb-params-for-coab.bash

#This run a unit test script designed to detect bug in the extraction script
#This is currently only triggered within the noop model
# shellcheck disable=SC2086
${COA_HOOKS_DIR}/test-extract-x-osb-cmdb-params-for-coab.bash