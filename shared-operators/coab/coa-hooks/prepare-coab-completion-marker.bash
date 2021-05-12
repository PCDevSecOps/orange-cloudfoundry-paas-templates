#!/bin/bash
#===========================================================================

set -o errexit # exit on errors

GENERATE_DIR=${GENERATE_DIR:-.}
CUSTOM_SCRIPT_DIR=${CUSTOM_SCRIPT_DIR:-template-resource}
SECRETS_DIR=${SECRETS_DIR:-.}

echo "use and generate file at $GENERATE_DIR"
echo "use template dir: <$CUSTOM_SCRIPT_DIR>  and secrets dir: <$SECRETS_DIR>"

####### end common header ######

#--- Colors and styles
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'

# Duplicate coab-vars.yml into coab-completion-marker.yml with a top-level single field `coab_completion_marker`. This makes it easy to insert it into the manifest through
function copy_coab_vars_to_coab_fingerprint_vars() {
  printf "coab_completion_marker:\n" >"${GENERATE_DIR}/coab-completion-marker-vars.yml"
  #Typical coab-vars.yml file: (starts with document separator --- that we need to remove)
  # ---
  #deployment_name: "x_e5f92172-52c2-4e2c-99af-b0ca8a70f160"
  #instance_id: "e5f92172-52c2-4e2c-99af-b0ca8a70f160"
  #service_id: "noop-ondemand-service"
  #plan_id: "noop-ondemand-plan"
  #[...]
  cat "${GENERATE_DIR}/coab-vars.yml" | grep -v '^---' | sed 's/^/   /' >>"${GENERATE_DIR}/coab-completion-marker-vars.yml"
  echo "adapted coab-vars.yml into coab-completion-marker-vars.yml"
  ls -al "${GENERATE_DIR}/coab-completion-marker-vars.yml"
  cat "${GENERATE_DIR}/coab-completion-marker-vars.yml"
}
copy_coab_vars_to_coab_fingerprint_vars

####### end treatment ######
