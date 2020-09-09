#!/bin/bash

deploy=cfcr
depls=cfcr-common-serv
final_name="10-${deploy}"

source ../../../../shared-operators/tools/add-symlink.sh


# delete 10-cfcr-tpl.yml as this common file is only use for deployment ON k8s
# and must not be present in cfcr deployment
rm 10-cfcr-tpl.yml
mv cfcr.yml 10-cfcr.yml