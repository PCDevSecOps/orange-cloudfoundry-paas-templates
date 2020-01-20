#!/bin/bash
set -x
#===========================================================================
# $1 root deployment
#===========================================================================

ROOT_DEPLOYMENT=$1
DEPLOYMENTS="cf-rabbit|cf-rabbit37|cloudfoundry-mysql|cloudfoundry-mysql-osb|guardian-uaa|guardian-uaa-prod|mongodb"
SHIELD_OPERATORS_RELATIVE_PATH="../../../shared-operators/shield"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}-depls/${deployment}/template
#    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/fix-shield-version-operators.yml 99-fix-shield-version-operators.yml
#    rm 99-fix-shield-version-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/fix-shield-version6_8_0-operators.yml zzz-fix-shield-version-operators.yml
    #rm zzz-fix-shield-version-operators.yml
    cd -
done

