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

####### end common header ######

#--- Colors and styles
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'

# retrieve and display plan_if from coab-vars.yml
PLAN_ID=$(bosh int "${GENERATE_DIR}/coab-vars.yml" --path /plan_id)
echo $PLAN_ID

#search for disabled vars matching plan_if
#if found copy it from TEMPLATE_DIR to GENERATE_DIR with the COA naming convention
for j in `find $BASE_TEMPLATE_DIR -name "mongodb-vars*.yml" | awk -F "vars_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
    if [ $PLAN_ID = $j ] ; then
        echo "copy from $BASE_TEMPLATE_DIR/mongodb-vars_$j.yml to $GENERATE_DIR/mongodb-vars.yml"
        cp $BASE_TEMPLATE_DIR/mongodb-vars_$j.yml $GENERATE_DIR/mongodb-vars.yml
    fi
done

####### end treatment ######