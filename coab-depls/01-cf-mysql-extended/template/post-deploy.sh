#!/bin/sh -e
#===========================================================================
# This hook script aims to :
# Create uaa client for dedicated shield (using cf-uaac cli)
# Run Errand import shield
# Init and unlock the shield webui (using shield cli)
# change schedule time backup
#===========================================================================

GENERATE_DIR=${GENERATE_DIR:-.}
BASE_TEMPLATE_DIR=${BASE_TEMPLATE_DIR:-template}
SECRETS_DIR=${SECRETS_DIR:-.}

echo "use and generate file at $GENERATE_DIR"
echo "use template dir: <$BASE_TEMPLATE_DIR>  and secrets dir: <$SECRETS_DIR>"

####### end common header ######