#!/bin/bash

set -o errexit    # exit on errors
export DEBUGGING_HINT_CMD="scripts-resource/concourse/tasks/post_deploy/run.sh"

# necessary for coab to track deployment completion in resulting manifest
# shellcheck disable=SC2086
${CUSTOM_SCRIPT_DIR}/verify-coab-completion-marker.bash