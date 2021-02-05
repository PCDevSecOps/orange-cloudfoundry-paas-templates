#!/bin/bash

export PLAN=small
#export DEBUG_MODE=true

#Load coab defaults
source ${BASE_TEMPLATE_DIR}/coab-post-deploy-defaults.bash

#Proceed with coab broker steps
${BASE_TEMPLATE_DIR}/common-post-deploy.sh
