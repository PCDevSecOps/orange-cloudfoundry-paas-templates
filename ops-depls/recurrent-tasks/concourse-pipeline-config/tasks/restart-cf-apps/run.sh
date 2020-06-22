#!/bin/sh

set -e
set -o pipefail

validate(){
    FAILURE=0
    if [ -z "$CF_API_URL" ]
    then
        echo "missing CF_API_URL"
        FAILURE=$((1 + $FAILURE))
    fi

    if [ -z "$CF_USERNAME" ]
    then
        echo "missing CF_USERNAME"
        FAILURE=$((2 + $FAILURE))
    fi

    if [ -z "$CF_PASSWORD" ]
    then
        echo "missing CF_PASSWORD"
        FAILURE=$((4 + $FAILURE))
    fi

    if [ $FAILURE -ne 0 ]
    then
        exit $FAILURE
    fi
}

validate

CURRENT_DIR=$(pwd)
OUTPUT_DIR=${OUTPUT_DIR:-${CURRENT_DIR}/generated-files}

API_OPTIONS="--skip-ssl-validation"

#TODO add an option to manage ssl validation
cf api "$CF_API_URL" $API_OPTIONS
cf auth "$CF_USERNAME" "$CF_PASSWORD"

cf target -o "$CF_ORG" -s "$CF_SPACE"

CF_APPLICATIONS=$(cf apps |tail -n +5|cut -d' ' -f1)
echo "Applications detected: ${CF_APPLICATIONS}"
global_return_code=0
set +e
for app in ${CF_APPLICATIONS};do
    cf restart ${app} |tee -a ${OUTPUT_DIR}/cf-${app}-restart.log
    ret_code=$?
    if [ $ret_code -ne 0 ]
    then
        DISPLAY_LOG_CMD=$(grep "TIP: use 'cf logs" ${OUTPUT_DIR}/cf-${app}-restart.log|cut -d\' -f2)
        eval $DISPLAY_LOG_CMD
    fi
    global_return_code=$(expr ${global_return_code} + ${ret_code})
done

exit ${global_return_code}
