#!/bin/bash

ln -sf ../cloudfoundry-mysql-osb/deployment-dependencies.yml deployment-dependencies.yml

cd template
ln -sf ../../../submodules/orange-cf-mysql-deployment/operations/no-arbitrator.yml 01-no-arbitrator-operators.yml
ln -sf ../../../submodules/orange-cf-mysql-deployment/operations/add-broker.yml 02-add-broker-operators.yml
ln -sf ../../../submodules/orange-cf-mysql-deployment/operations/add-roadmin.yml 03-add-roadmin-operators.yml
ln -sf ../../../submodules/orange-cf-mysql-deployment/operations/register-proxy-route.yml 04-register-proxy-route-operators.yml
ln -sf ../../../submodules/orange-cf-mysql-deployment/operations/disable-broker-route-registrar-cross-deployment-links.yml 05-operator-disable-broker-route-registrar-cross-deployment-links-operators.yml
ln -sf ../../../submodules/orange-cf-mysql-deployment/operations/disable-proxy-route-registrar-cross-deployment-links.yml 07-operator-disable-proxy-route-registrar-cross-deployment-links-operators.yml
ln -sf ../../../submodules/orange-cf-mysql-deployment/operations/disable-smoke-tests-cross-deployment-links.yml 08-operator-disable-smoke-tests-cross-deployment-links-operators.yml
cd -

cd template
ln -sf ../../../shared-operators/shield/add-mc-job-operators.yml 40-shieldv8-add-mc-job-operators.yml
ln -sf ../../../shared-operators/shield/add-release-minio-operators.yml 40-shieldv8-add-release-minio-operators.yml
ln -sf ../../../shared-operators/shield/add-release-scripting-operators.yml 40-shieldv8-add-release-scripting-operators.yml
ln -sf ../../../shared-operators/shield/add-release-shield-operators.yml 40-shieldv8-add-release-shield-operators.yml
ln -sf ../../../shared-operators/shield/add-shield-agent-job-operators.yml 40-shieldv8-add-shield-agent-job-operators.yml
ln -sf ../../../shared-operators/shield/add-shield-agent-proxy-operators.yml 40-shieldv8-add-shield-agent-proxy-operators.yml
ln -sf ../../../shared-operators/shield/add-shield-import-systems-mariabackup-errand-operators.yml 40-shieldv8-add-shield-import-asystem-mariabackup-errand-operators.yml
ln -sf ../../../shared-operators/shield/add-shield-import-members-errand-operators.yml 40-shieldv8-add-shield-import-members-errand-operators.yml
ln -sf ../../../shared-operators/shield/add-shield-import-policies-errand-operators.yml 40-shieldv8-add-shield-import-policies-errand-operators.yml
ln -sf ../../../shared-operators/shield/add-shield-import-storage-errand-operators.yml 40-shieldv8-add-shield-import-storage-errand-operators.yml
ln -sf ../../../shared-operators/shield/create-bucket-scripting-operators.yml 40-shieldv8-create-bucket-scripting-operators.yml
ln -sf ../../../shared-operators/shield/create-bucket-scripting-pre-start-only-operators.yml 40-shieldv8-create-bucket-scripting-pre-start-only-operators.yml
ln -sf ../../../shared-operators/shield/modify-mysql-schedule-scripting-post-deploy-operators.yml 40-shieldv8-modify-schedule-scripting-post-deploy-operators.yml
cd -

cd template
for link in $(find ../../cloudfoundry-mysql-osb/template -maxdepth 1 -type f -name '*'); do
    bnlink=$(basename ${link})
    echo ${bnlink}
    ln -sf ../../cloudfoundry-mysql-osb/template/${bnlink} ${bnlink}
done
cd -

cd template
mkdir -p 91-paas-templates-version
ln -sf ../../../../shared-operators/paas-templates-version/91-paas-templates-version-operators.yml 91-paas-templates-version/91-paas-templates-version-operators.yml
ln -sf ../../../../shared-operators/paas-templates-version/91-paas-templates-version-vars-tpl.yml 91-paas-templates-version/91-paas-templates-version-vars-tpl.yml
cd -

cd template
mkdir -p openstack-hws
ln -sf ../../../../shared-operators/shield/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
ln -sf ../../cloudfoundry-mysql-osb/template/openstack-hws/30-register-osbbroker-operators.yml openstack-hws/30-register-osbbroker-operators.yml
ln -sf ../../cloudfoundry-mysql-osb/template/openstack-hws/31-add-cf-cli-operators.yml openstack-hws/31-add-cf-cli-operators.yml
ln -sf ../../cloudfoundry-mysql-osb/template/openstack-hws/vm-extensions-operators.yml openstack-hws/vm-extensions-operators.yml
cd -

cd template
mkdir -p vsphere
ln -sf ../../../../shared-operators/shield/shieldv8-proxy-internet-vars.yml vsphere/shieldv8-proxy-internet-vars.yml
cd -

