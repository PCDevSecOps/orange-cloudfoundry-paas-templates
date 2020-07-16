#!/bin/bash

deploy=cfcr
depls=cfcr-common-master
final_name="${deploy}"

source ../../../../shared-operators/tools/add-symlink.sh


# delete 10-cfcr-tpl.yml as this common file is only use for deployment ON k8s
# and must not be present in cfcr deployment
rm cfcr-tpl.yml
mv cfcr.yml cfcr.yml