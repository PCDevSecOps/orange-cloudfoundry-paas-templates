#!/bin/bash
#set -x
#===========================================================================
# $1 root deployment
# $2 deployment
# usage : ./_enable_shieldv8.sh master-depls "bosh-coab|bosh-kubo"
#===========================================================================

PREFIX="2-shieldv8"
SUFFIX="-DISABLED"
EMPTY=""
SHIELD_OPERATORS_RELATIVE_PATH="../../../shared-operators/shield"

ROOT_DEPLOYMENT=$1
DEPLOYMENTS=$2
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    for file in $(find . -name '*shieldv8-*operators*'); do
        #echo "file : ${file}";
        #echo "replace : ${file/$SUFFIX/$EMPTY}";
        git mv ${file} ${file/$SUFFIX/$EMPTY}
    done
    git mv zzz-fix-shield-version-operators.yml zzz-fix-shield-version-operators-DISABLED.yml
    shield=$(find . -name '*shield-backup*')
    git mv ${shield} ${shield/"-operators"/"-operators-DISABLED"}
    sed -i -e "s/#    errands:/    errands:/g" ../deployment-dependencies.yml
    sed -i -e "s/#      - import/      - import/g" ../deployment-dependencies.yml
    cd -
done
