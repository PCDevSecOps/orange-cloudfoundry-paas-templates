#!/bin/bash

deploy=k8s
depls=k8s-common-serv
final_name="10-${deploy}"

source ../../../../shared-operators/tools/add-symlink.sh
rm 10-k8s-tpl.yml
mv k8s.yml 10-k8s.yml