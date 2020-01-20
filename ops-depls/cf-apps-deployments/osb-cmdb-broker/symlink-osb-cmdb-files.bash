#!/bin/bash

# this is designed to run by paas-templates authors in their desktop in order to maintain symlinked osb-cmdn

# See https://superuser.com/questions/356804/create-symlinks-recursively-for-a-whole-tree
#Need to install lndir

function is_command_defined {
    # https://stackoverflow.com/a/677212/1484823  how-to-check-if-a-program-exists-from-a-bash-script
    if ! type -a $1 > /dev/null 2>&1
    then
        return 1
    fi
}


if ! is_command_defined lndir ; then
    sudo apt-get install xutils-dev
fi
set -x
set -e

cd ops-depls/cf-apps-deployments/
date > osb-cmdb-broker/template/bump-shared-content-on.txt
git add osb-cmdb-broker/template/bump-shared-content-on.txt
for d in 0 1 2 3 4 ; do
    SYMLINKED_DIR="osb-cmdb-broker-${d}/template"
    mkdir -p ${SYMLINKED_DIR}
    pushd ${SYMLINKED_DIR}
    lndir ../../osb-cmdb-broker/template
    # COA enforces consistency between manifest file and deployment name, so need to rename it
    rm osb-cmdb-broker*_manifest-tpl.yml
    ls -al
    SUFFIXED_MANIFEST_FILE="osb-cmdb-broker-${d}_manifest-tpl.yml"
    cp ../../osb-cmdb-broker/template/osb-cmdb-broker_manifest-tpl.yml ${SUFFIXED_MANIFEST_FILE}
    # Plus hostnames need to change to avoid conflicts
    sed --in-place "s/host: osb-cmdb-broker/host: osb-cmdb-broker-${d}/" ${SUFFIXED_MANIFEST_FILE}
    # Plus appname needs to change to avoid deviating from common-broker-scripts convention: appname == space name
    sed --in-place "s/name: osb-cmdb-broker/name: osb-cmdb-broker-${d}/" ${SUFFIXED_MANIFEST_FILE}
    date > ../bump-shared-content-on.txt
    git add * ../bump-shared-content-on.txt
    popd
done



echo "please review and commit symlinked dirs"
