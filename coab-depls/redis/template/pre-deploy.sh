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

ROOT_DIR=$(pwd)
STATUS_FILE="/tmp/$$.res"
SHARED_SECRETS="${ROOT_DIR}/credentials-resource/shared/secrets.yml"
INTERNAL_CA_CERT="${ROOT_DIR}/credentials-resource/shared/certs/internal_paas-ca/server-ca.crt"

#--- Retrieve deployment name
printf "%bRetrieve deployment name...%b\n" "${YELLOW}" "${STD}"
DEPLOYMENT=`basename ${SECRETS_DIR}`
echo "deployment : ${DEPLOYMENT}"

# retrieve and display plan_if from coab-vars.yml
PLAN_ID=$(bosh int "${GENERATE_DIR}/coab-vars.yml" --path /plan_id)
echo $PLAN_ID

expand_file_if_it_matches_plan_id(){
  plan=$1;pattern=$2;prefix=$3;key=$4
  for j in `find $BASE_TEMPLATE_DIR -name ${pattern} | awk -F ${key} '{ print $2 }' | awk -F "." '{ print $1 }'`; do
    if [ ${plan} = $j ] ; then
        echo "copy from $BASE_TEMPLATE_DIR/${prefix}_$j.yml to $GENERATE_DIR/${prefix}.yml"
        cp $BASE_TEMPLATE_DIR/${prefix}_$j.yml $GENERATE_DIR/${prefix}.yml
    fi
  done
}
expand_file_if_it_matches_plan_id ${PLAN_ID} "01-operator-cf-service-broker-operators*.yml" "01-operator-cf-service-broker-operators" "operators_"
expand_file_if_it_matches_plan_id ${PLAN_ID} "40-enable-prometheus-exporter-operators*.yml" "40-enable-prometheus-exporter-operators" "operators_"
expand_file_if_it_matches_plan_id ${PLAN_ID} "82-add-monitoring-custom-addon-operators*.yml" "82-add-monitoring-custom-addon-operators" "operators_"
expand_file_if_it_matches_plan_id ${PLAN_ID} "82-add-monitoring-custom-addon-redis-sentinel-operators*.yml" "82-add-monitoring-custom-addon-redis-sentinel-operators" "operators_"
expand_file_if_it_matches_plan_id ${PLAN_ID} "redis-vars*.yml" "redis-vars" "vars_"

# MANIFEST specific
for j in `find $BASE_TEMPLATE_DIR -name "redis-manifest*.yml" | awk -F "manifest_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
    if [ $PLAN_ID = $j ] ; then
        echo "copy from $BASE_TEMPLATE_DIR/redis-manifest_$j.yml to $GENERATE_DIR/${DEPLOYMENT}.yml"
        cp $BASE_TEMPLATE_DIR/redis-manifest_$j.yml $GENERATE_DIR/${DEPLOYMENT}.yml
    fi
done

# IAAS-TYPE specific
SITE_PATH="/secrets/site"
is_brmc=$(bosh int ${SHARED_SECRETS} --path ${SITE_PATH} | grep "brmc" | wc -l)
if [ ${is_brmc} -eq 1 ] ; then
    for j in `find $BASE_TEMPLATE_DIR/vsphere -name "99-osb-operators*.yml" | awk -F "operators_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
        if [ $PLAN_ID = $j ] ; then
            echo "copy from $BASE_TEMPLATE_DIR/vsphere/99-osb-operators_$j.yml to $GENERATE_DIR/99-osb-operators.yml"
            cp $BASE_TEMPLATE_DIR/vsphere/99-osb-operators_$j.yml $GENERATE_DIR/99-osb-operators.yml
        fi
    done
fi

# generate fake coab vars file if brokered_service_instance_guid not present in coab-vars.yml
${CUSTOM_SCRIPT_DIR}/generate-fake-coab-vars-when-vars-are-missing.bash

# necessary for coab to track deployment completion in resulting manifest
# shellcheck disable=SC2086
${CUSTOM_SCRIPT_DIR}/prepare-coab-completion-marker.bash

####### end treatment ######