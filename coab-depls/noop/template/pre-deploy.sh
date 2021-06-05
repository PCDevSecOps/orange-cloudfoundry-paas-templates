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