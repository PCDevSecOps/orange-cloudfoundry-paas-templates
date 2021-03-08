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

#search for disabled operators matching plan_if
#if found copy it from TEMPLATE_DIR to GENERATE_DIR with the COA naming convention
#for j in `find $BASE_TEMPLATE_DIR -name "plan-operators*.yml" | awk -F "_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
#    if [ $PLAN_ID = $j ] ; then
#        echo "copy from $BASE_TEMPLATE_DIR/plan-operators_$j.yml to $GENERATE_DIR/plan-operators.yml"
#        cp $BASE_TEMPLATE_DIR/plan-operators_$j.yml $GENERATE_DIR/plan-operators.yml
#    fi
#done
#search for disabled vars matching plan_if
#if found copy it from TEMPLATE_DIR to GENERATE_DIR with the COA naming convention

# OPERATOR 01-operator-cf-service-broker-operators
for j in `find $BASE_TEMPLATE_DIR -name "01-operator-cf-service-broker-operators*.yml" | awk -F "operators_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
    if [ $PLAN_ID = $j ] ; then
        echo "copy from $BASE_TEMPLATE_DIR/01-operator-cf-service-broker-operators_$j.yml to $GENERATE_DIR/01-operator-cf-service-broker-operators.yml"
        cp $BASE_TEMPLATE_DIR/01-operator-cf-service-broker-operators_$j.yml $GENERATE_DIR/01-operator-cf-service-broker-operators.yml
    fi
done

# OPERATOR 40-enable-prometheus-exporter-operators
for j in `find $BASE_TEMPLATE_DIR -name "40-enable-prometheus-exporter-operators*.yml" | awk -F "operators_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
    if [ $PLAN_ID = $j ] ; then
        echo "copy from $BASE_TEMPLATE_DIR/40-enable-prometheus-exporter-operators_$j.yml to $GENERATE_DIR/40-enable-prometheus-exporter-operators.yml"
        cp $BASE_TEMPLATE_DIR/40-enable-prometheus-exporter-operators_$j.yml $GENERATE_DIR/40-enable-prometheus-exporter-operators.yml
    fi
done

# MANIFEST
for j in `find $BASE_TEMPLATE_DIR -name "redis-manifest*.yml" | awk -F "manifest_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
    if [ $PLAN_ID = $j ] ; then
        echo "copy from $BASE_TEMPLATE_DIR/redis-manifest_$j.yml to $GENERATE_DIR/${DEPLOYMENT}.yml"
        cp $BASE_TEMPLATE_DIR/redis-manifest_$j.yml $GENERATE_DIR/${DEPLOYMENT}.yml
    fi
done

# PLAN
for j in `find $BASE_TEMPLATE_DIR -name "redis-vars*.yml" | awk -F "vars_" '{ print $2 }' | awk -F "." '{ print $1 }'`; do
    if [ $PLAN_ID = $j ] ; then
        echo "copy from $BASE_TEMPLATE_DIR/redis-vars_$j.yml to $GENERATE_DIR/redis-vars.yml"
        cp $BASE_TEMPLATE_DIR/redis-vars_$j.yml $GENERATE_DIR/redis-vars.yml
    fi
done

# IAAS-TYPE
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

# necessary for coab to track deployment completion in resulting manifest
# shellcheck disable=SC2086
${CUSTOM_SCRIPT_DIR}/prepare-coab-completion-marker.bash

####### end treatment ######