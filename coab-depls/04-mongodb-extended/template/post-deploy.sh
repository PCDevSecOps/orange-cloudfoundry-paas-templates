#!/bin/sh -e
#===========================================================================
# This hook script aims to :
# Create uaa client for dedicated shield (using cf-uaac cli)
# Init and unlock the shield webui (using shield cli)
#===========================================================================

GENERATE_DIR=${GENERATE_DIR:-.}
BASE_TEMPLATE_DIR=${BASE_TEMPLATE_DIR:-template}
SECRETS_DIR=${SECRETS_DIR:-.}

echo "use and generate file at $GENERATE_DIR"
echo "use template dir: <$BASE_TEMPLATE_DIR>  and secrets dir: <$SECRETS_DIR>"

# necessary for coab to track deployment completion in resulting manifest
# shellcheck disable=SC2086
${CUSTOM_SCRIPT_DIR}/verify-coab-completion-marker.bash

####### end common header ######
