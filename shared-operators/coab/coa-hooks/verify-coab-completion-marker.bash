#!/bin/bash
#===========================================================================
# This hook script aims to :
# - Assert the manifest file includes coab OSB request
#===========================================================================

set -o errexit    # exit on errors

GENERATE_DIR=${GENERATE_DIR:-.}
CUSTOM_SCRIPT_DIR=${CUSTOM_SCRIPT_DIR:-template-resource}
SECRETS_DIR=${SECRETS_DIR:-.}

echo "executing $0"
echo "use and generate file at $GENERATE_DIR"
echo "use template dir: <$CUSTOM_SCRIPT_DIR>  and secrets dir: <$SECRETS_DIR>"

####### end common header ######

echo "Checking COAB deployment completion marker matches COAB deployment request marker"

source $CUSTOM_SCRIPT_DIR/../../common-broker-scripts/common-lib.bash

#--- Retrieve deployment name
DEPLOYMENT_NAME=$(basename "${SECRETS_DIR}")
echo "deployment name is: ${DEPLOYMENT_NAME}"
BOSH_MANIFEST_FILE_NAME="${DEPLOYMENT_NAME}.yml"

#Fetch manifest property and fail if missing
fetch_secret_prop "$SECRETS_DIR/${BOSH_MANIFEST_FILE_NAME}" /coab_completion_marker > /tmp/coab-deployment-completion-marker.yml

echo "coab_completion_marker is: "
cat /tmp/coab-deployment-completion-marker.yml

#Fetch and normalize yaml formatting of coab-vars to prepare comparison
bosh int $CUSTOM_SCRIPT_DIR/coab-vars.yml > /tmp/coab-deployment-request-marker.yml

echo "Comparing /tmp/coab-deployment-request-marker.yml /tmp/coab-deployment-completion-marker.yml"

# Would return non zero exit status if differing, and thus fail
diff /tmp/coab-deployment-request-marker.yml /tmp/coab-deployment-completion-marker.yml

echo "Ok markers are matching, COAB would detect the deployment request as complete."