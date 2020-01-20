#!/bin/bash
#set -x
#===========================================================================
# $1 root deployment
# $2 deployment
# usage : ./_disable_shieldv8.sh master-depls "bosh-coab|bosh-kubo"
#===========================================================================

PREFIX="2-shieldv8"
SOURCE="-operators"
TARGET="-operators-DISABLED"
SHIELD_OPERATORS_RELATIVE_PATH="../../../shared-operators/shield"

ROOT_DEPLOYMENT=$1
DEPLOYMENTS=$2
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    for file in $(find . -name '*shieldv8-*operators*'); do
        #echo "file : ${file}";
        #echo "replace : ${file/$SOURCE/$TARGET}";
        git mv ${file} ${file/$SOURCE/$TARGET}
    done
    git mv zzz-fix-shield-version-operators-DISABLED.yml zzz-fix-shield-version-operators.yml
    shield=$(find . -name '*shield-backup-operators-DISABLED*')
    git mv ${shield} ${shield/"-operators-DISABLED"/"-operators"}
    sed -i -e "s/    errands:/#    errands:/g" ../deployment-dependencies.yml
    sed -i -e "s/      - import/#      - import/g" ../deployment-dependencies.yml
    cd -
done
