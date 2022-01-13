#!/bin/bash

root_deployment=remote-r3-depls
cd ${root_deployment}
for deployment in $(find . -maxdepth 1 -type d); do
  echo "processing deployment : ${deployment}"
  directory=$(basename ${deployment})
  echo ${directory}
#  coab-depls
#  if [ "${directory}" != "." ]&&[ "${directory}" != "model-migration-pipeline" ]&&[ "${directory}" != "ops-scripts" ]&&[ "${directory}" != "cf-apps-deployments" ]&&[ "${directory}" != "common-broker-scripts" ]&&[ "${directory}" != "terraform-config" ]&&[ "${directory}" != "template" ] ; then
#  master-depls
#  micro-depls
#  if [ "${directory}" != "." ]&&[ "${directory}" != "auto-sanitize" ]&&[ "${directory}" != "release-mgmt" ]&&[ "${directory}" != "release-mgmt-github" ]&&[ "${directory}" != "terraform-config" ]&&[ "${directory}" != "template" ]&&[ "${directory}" != "retrigger-all-deployments" ] ; then

  if [ "${directory}" != "." ]&&[ "${directory}" != "terraform-config" ]&&[ "${directory}" != "template" ] ; then
    cd ${directory}/template
    mkdir -p 91-paas-templates-version
    cd 91-paas-templates-version
    echo "entering directory : ${directory}/template/91-paas-templates-version"
    ln -s ../../../../shared-operators/paas-templates-version/91-paas-templates-version-operators.yml 91-paas-templates-version-operators.yml
    ln -s ../../../../shared-operators/paas-templates-version/91-paas-templates-version-vars-tpl.yml 91-paas-templates-version-vars-tpl.yml
    #unlink 91-paas-templates-version-operators.yml
    #unlink 91-paas-templates-version-vars-tpl.yml
    cd ../../..
  fi
done
cd ..
