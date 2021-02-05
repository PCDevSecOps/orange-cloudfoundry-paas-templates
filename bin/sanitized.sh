#!/usr/bin/env bash

usage() {
    echo "$0 [-f]"
    echo "  removes all non sanitize files from paas-templates. Only executes a dry run, by default."
    echo "      -f: effectively delete non sanitized files."
    exit 1
}

. ./load-git-secrets-env.sh

# $1: /absolute/path/to/file.text
function replace_file_with_redacted_symlink () {
    for FILE_PATH in $@; do
      # Do not double quote to allow glob expansion
      if [ ! -f ${FILE_PATH} ]; then
          echo "Asked to delete a file which is now missing: ${FILE_PATH}"
          echo "Please update sanitized.sh"
          #Once we merge the feature-automated-sanitize branch into develop then fail fast
          #For now the same sanitized.sh file is used for cleaning both develop and wip-merged... branches
          #exit 1
      else
          rm -v ${FILE_PATH}
          #This creates a dangling symlink
          ln -nfs temporarly-redacted-content ${FILE_PATH}
      fi
    done
}

function dry_run(){
    # Do not double quote to allow glob expansion
    for FILE_PATH in $@; do
      if [ ! -f ${FILE_PATH} ]; then
          echo "Please update sanitized.sh: asked to delete a file which is now missing: ${FILE_PATH}"
          #Once we merge the feature-automated-sanitize branch into develop then fail fast
          #For now the same sanitized.sh file is used for cleaning both develop and wip-merged... branches
          #exit 1
      else
          echo "Will remove: ${FILE_PATH}"
      fi
    done
}

RM_CMD=dry_run
ROOT_DIR=".."
while getopts ":f" option; do
    case "${option}" in
        f)
            RM_CMD=replace_file_with_redacted_symlink
            #RM_CMD="rm -v"
            ;;
        \?)
            echo "Invalid option: $OPTARG" >&2
            usage
            ;;
        *)
            usage
            ;;
    esac
done

set +e

echo "Starting  sanitization !!!"

${RM_CMD} ${ROOT_DIR}/admin/rebase-paas-templates-branches.sh

${RM_CMD} ${ROOT_DIR}/admin/certs_rotation.md

${RM_CMD} ${ROOT_DIR}/admin/recreate-inception.sh

${RM_CMD} ${ROOT_DIR}/admin/recreate-micro-bosh.sh

${RM_CMD} ${ROOT_DIR}/admin/send-mail.sh

${RM_CMD} ${ROOT_DIR}/bootstrap/README_BRMC.md

${RM_CMD} ${ROOT_DIR}/bootstrap/README_FE.md

${RM_CMD} ${ROOT_DIR}/bootstrap/inception/template/openstack-hws/tpl-secrets.yml

${RM_CMD} ${ROOT_DIR}/bootstrap/inception/template/vsphere/tpl-secrets.yml

${RM_CMD} ${ROOT_DIR}/bootstrap/micro-bosh/template/micro-bosh-operators.yml

${RM_CMD} ${ROOT_DIR}/bootstrap/tools/configure-openstack.sh

${RM_CMD} ${ROOT_DIR}/bootstrap/tools/create-inception.sh

${RM_CMD} ${ROOT_DIR}/bootstrap/tools/functions.sh

${RM_CMD} ${ROOT_DIR}/cloudflare-depls/terraform-config/README

${RM_CMD} ${ROOT_DIR}/cloudflare-depls/terraform-config/spec/cloudfoundry-provider.tf

${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/30-context-patch-broker-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/50-enable-prometheus-exporter-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/71-add-shield-core-to-broker-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/72-add-shield-agent-to-mysql-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/cf-mysql-extended-common-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/prometheus-vars.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/shield-vars.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/02-redis-extended/template/03-operator-cf-service-broker-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/02-redis-extended/template/post-deploy.sh

${RM_CMD} ${ROOT_DIR}/coab-depls/10-k8s-crunchy-osb/template/10-embedded-cfcr-k8s/pgo-osb-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/10-k8s-crunchy-osb/template/10-metalikaas-k8s/04-deployment-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-broker/install/2_coab-cfapp-deployment/coa-cf-mysql-broker/disable-cf-app.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-broker/install/2_coab-cfapp-deployment/coa-cf-mysql-broker/s/s.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-broker/install/releasenote.md

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-extended-broker/install/2_coab-cfapp-deployment/coa-cf-mysql-extended-broker/disable-cf-app.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-extended-broker/install/2_coab-cfapp-deployment/coa-cf-mysql-extended-broker/s/s.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-extended-broker/install/releasenote.md

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-rabbit-broker/install/2_coab-cfapp-deployment/coa-cf-rabbit-broker/disable-cf-app.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-rabbit-broker/install/2_coab-cfapp-deployment/coa-cf-rabbit-broker/s/s.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-rabbit-broker/install/releasenote.md

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-mongodb-broker/install/2_coab-cfapp-deployment/coa-mongodb-broker/disable-cf-app.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-mongodb-broker/install/2_coab-cfapp-deployment/coa-mongodb-broker/s/s.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-mongodb-broker/install/releasenote.md

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-mongodb-broker/template/broker-catalog-config-tpl.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-noop-broker/template/coa-noop-broker_manifest-tpl.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-broker/install/2_coab-cfapp-deployment/coa-redis-broker/disable-cf-app.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-broker/install/2_coab-cfapp-deployment/coa-redis-broker/s/s.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-broker/install/releasenote.md

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-broker/template/broker-catalog-config-tpl.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-extended-broker/install/2_coab-cfapp-deployment/coa-redis-extended-broker/disable-cf-app.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-extended-broker/install/2_coab-cfapp-deployment/coa-redis-extended-broker/s/s.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-extended-broker/install/releasenote.md

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-extended-broker/template/broker-catalog-config-tpl.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/02-operator-add-broker-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/30-context-patch-broker-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/40-enable-prometheus-exporter-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/71-enable-shieldv8-shield-core-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/72-enable-shieldv8-shield-cf-mysql-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/cf-mysql-vars_plan-coab-mariadb-*.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/openstack-hws/shield-vars.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/prometheus-vars.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/shield-vars.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-rabbit/template/cf-rabbitmq-37-vars.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-rabbit/template/openstack-hws/shield-vars.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/cf-rabbit/template/shield-vars.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/common-broker-scripts/post-deploy.sh

${RM_CMD} ${ROOT_DIR}/coab-depls/model-migration-pipeline/concourse-pipeline-config/migrate_coab_pipeline_test.sh

${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/01-enable-mongodb-broker-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/02-enable-mongodb-broker-smoke-tests-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/40-enable-prometheus-exporter-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/42-enable-shieldv8-standalone-operators-DISABLED.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/71-enable-shieldv8-shield-core-operators*.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/72-enable-shieldv8-shield-mongod-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/mongodb.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/openstack-hws/shield-vars.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/shield-vars.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/ops-scripts/clean_service_instance_leaks.sh

${RM_CMD} ${ROOT_DIR}/coab-depls/redis/template/01-operator-cf-service-broker-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/redis/template/01-operator-cf-service-broker-operators_plan-coab-redis-sentinelsmall.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/redis/template/01-operator-cf-service-broker-operators_plan-coab-redis-small.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/shield/template/1-context-patch-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/shield/template/shield-vars.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/spec/*-service-broker.tf

${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/spec/cloudfoundry.tf

${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/template/openstack-hws/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/template/vsphere/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/master-depls/bosh-coab/template/80-r2-vsphere/9-http-proxy-for-vsphere-r2-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/cf-autoscaler/template/cf-autoscaler.yml

${RM_CMD} ${ROOT_DIR}/master-depls/cf/template/3-custom-uaa-clients-autoscaler-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/cf/template/openstack-hws/8-add-sandbox-pause-cron-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/cf/template/terraform-specs/cf-spec.tf

${RM_CMD} ${ROOT_DIR}/master-depls/k8s-metabase/doc/first_install.md

${RM_CMD} ${ROOT_DIR}/master-depls/k8s-metabase/provisioning/metabase-statefeprod-cc.json

${RM_CMD} ${ROOT_DIR}/master-depls/k8s-metabase/provisioning/metabase-statefeprod.json

${RM_CMD} ${ROOT_DIR}/master-depls/k8s-metabase/provisioning/provisioning.md

${RM_CMD} ${ROOT_DIR}/master-depls/k8s-metabase/template/3-metabase-postgresql-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/k8s-metabase/template/4-metabase-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/logsearch-ops/template/8-add-oauth2-proxy-bosh-release-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/logsearch-ops/template/8-add-oauth2-proxy-operators.yml.DISABLED

${RM_CMD} ${ROOT_DIR}/master-depls/logsearch/template/firehose-uaa-client-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/metabase/template/70-enable-bi-cdc-event-infra/6-yugabyte-oauth2-proxy-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/prometheus-exporter-coab/template/prometheus-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/prometheus-exporter-master/template/openstack-hws/3-black-box-proxy-intranet-scrape-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/prometheus-exporter-ops/template/2-*-exporter-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/prometheus/template/4-enable-grafana-ldap-access-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/prometheus/template/5-credhub-scrape-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/prometheus/template/80-r2-openstack-hws/9-scrape-vpn-blackbox-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/prometheus/template/80-r2-vsphere/9-scrape-vpn-blackbox-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/prometheus/template/prometheus-tpl.yml

${RM_CMD} ${ROOT_DIR}/master-depls/rundeck/template/50-install-rundeck-helm-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/shieldv8/template/09-add-shield-import-system-bbr-deployment-*-errand-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/shieldv8/template/09-add-shield-import-system-bbr-director-bosh-micro-errand-operators.yml

${RM_CMD} ${ROOT_DIR}/master-depls/shieldv8/template/custom-shieldv8-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/master-depls/terraform-config/spec-openstack-hws/service-broker-autoscaler.tf

${RM_CMD} ${ROOT_DIR}/master-depls/terraform-config/spec/cf-provider.tf

${RM_CMD} ${ROOT_DIR}/master-depls/terraform-config/template/openstack-hws/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/master-depls/terraform-config/template/vsphere/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/00-core-connectivity-k8s/template/11-add-k3s-server-pxc-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/00-core-connectivity-terraform/template/openstack-hws/30-flexible-engine-provider-r1.tf

${RM_CMD} ${ROOT_DIR}/micro-depls/00-gitops-management/template/11-add-k3s-server-pxc-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/00-gitops-management/template/50-gitea-helm-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/00-gitops-management/template/50-install-kapp-controller-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/00-gitops-management/template/55-micro-k8s-kapp-config-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/00-gitops-management/template/65-micro-k8s-fleet-config-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/01-ci-k8s/template/11-add-k3s-server-pxc-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/auto-sanitize/concourse-pipeline-config/auto-sanitize.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/concourse/bootstrap/bootstrap-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/concourse/template/01-add-haproxy-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/concourse/template/openstack-hws/cf-sso-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/credhub-ha/template/1-credhub-backend-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/credhub-seeder/template/credhub-seeder-tpl.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/credhub-seeder/template/credhubcli-scripting-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/docker-bosh-cli/template/nginx/index-full-tpl.html

${RM_CMD} ${ROOT_DIR}/micro-depls/docker-bosh-cli/template/nginx/index-services-tpl.html

${RM_CMD} ${ROOT_DIR}/micro-depls/gitlab/template/1-gitlab-config-scripting-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-concourse/template/2-concourse-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-gitlab/template/2-gitlab-cert-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-gitlab/template/7-gitlab-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/prometheus-exporter-master/template/2-bosh-exporter-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/prometheus-exporter-master/template/openstack-hws/3-black-box-proxy-internet-scrape-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/prometheus-exporter-master/template/openstack-hws/3-black-box-scrape-operators.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/terraform-config/spec-openstack-hws/sg-internet.tf

${RM_CMD} ${ROOT_DIR}/micro-depls/terraform-config/template/openstack-hws/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/terraform-config/template/vsphere/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/db-dumper/template/db-dumper_manifest-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/db-dumper/template/post-deploy.sh

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/elpaaso-sandbox/doc/readme.md

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/huawei-cloud-osb-sample-app/template/pre-cf-push.sh

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/huawei-cloud-osb/template/config-json-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/matomo-brokers/template/matomo-intranet-broker_manifest-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/osb-reverse-proxy*/template/osb-reverse-proxy*_manifest-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/overview-broker/template/common-post-deploy.sh

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/postgresql-docker-broker/template/postgresql-cf-service-broker_manifest-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/postgresql-docker-test-app/template/server.js

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/users-portal/doc/readme.md

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/users-portal/template/conf/site.json

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/users-portal/template/pre-cf-push.sh

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-rabbit-osb/template/991-catalog-operators.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-rabbit-osb/template/cf-rabbitmq-37-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-rabbit-osb/template/custom-shieldv8-vars.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-rabbit37/template/cf-rabbit37-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-rabbit37/template/custom-shieldv8-vars.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-rabbit37/template/openstack-hws/30-register-osbbroker-operators.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-redis-osb/template/vsphere/991-catalog-operators.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-redis-osb/template/vsphere/cf-redis-vars.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-redis/template/cf-redis-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry-mysql-osb/template/991-catalog-operators.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry-mysql-osb/template/vsphere/cloudfoundry-mysql-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry-mysql/template/30-broker-patch-operators.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry-mysql/template/45-prometheus-mysqld-exporter-operators.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry-mysql/template/cloudfoundry-mysql-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-*.tf

${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec/cloudfoundry.tf

${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec/service-broker-intranet-proxy.tf

${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/template/openstack-hws/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/template/vsphere/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/concourse-dev/template/concourse-dev-tpl-old.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/concourse-dev/template/concourse-micro-reuse-old-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/concourse-dev/template/ldap-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/kafka/template/01-add-kafka-operators.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/kafka/template/02-add-kafka-broker-operators.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/mongodb-osb/template/991-catalog-operator.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/mongodb-osb/template/mongo-vars.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/mongodb-osb/template/vsphere/quota-enforcer-operators.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/mongodb/template/mongodb.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/postgresql-docker/template/postgresql-docker.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/recurrent-tasks/concourse-pipeline-config/recurrent-tasks.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/recurrent-tasks/concourse-pipeline-config/tasks/restart-cf-apps/task.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/vault/template/safe-broker-operators.yml

${RM_CMD} ${ROOT_DIR}/remote-r2-depls/terraform-config/template/80-r2-openstack-hws/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/remote-r2-depls/terraform-config/template/80-r2-vsphere/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/remote-r3-depls/template/cloud-config-tpl.yml

${RM_CMD} ${ROOT_DIR}/remote-r3-depls/terraform-config/template/80-r2-openstack-hws/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/remote-r3-depls/terraform-config/template/80-r2-vsphere/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/bosh/0-debug-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/bosh/2-config-server-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/bosh/2-hm-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/bosh/9-clean-bosh-directors-tasks-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-common-serv/10-metalikaas-k8s/k8s-deploy-serv-vars-tpl.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-crunchy/10-embedded-cfcr-k8s/4-configmap-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-crunchy/10-metalikaas-k8s/3-jobs-operators-deprecated.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-crunchy/10-metalikaas-k8s/4-configmap-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-falco/1-falco-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-flux/03-crd-helm-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-logging/4-elasticsearch-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-traefik/8-traefik-ingressroute-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-weavescope/02-apply-weavescope-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/k8s/03-0-control-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/multi-region-common/01-cf-mysql-extended/30-context-patch-broker-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/shield/add-shield-import-members-errand-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/shield/add-shield-import-system-bbr-deployment-master-depls-bosh-remote-r2-errand-operators.yml

${RM_CMD} ${ROOT_DIR}/shared-operators/shield/add-shield-import-system-bbr-deployment-master-depls-bosh-remote-r3-errand-operators.yml

${RM_CMD} ${ROOT_DIR}/upgrade/Upgrade_process.md

${RM_CMD} ${ROOT_DIR}/upgrade/common.sh

${RM_CMD} ${ROOT_DIR}/upgrade/load-paas-templates-upgrade-pipeline.sh

${RM_CMD} ${ROOT_DIR}/upgrade/load-prerequisite-pipeline.sh

${RM_CMD} ${ROOT_DIR}/upgrade/load-upgrade-pipeline.sh

${RM_CMD} ${ROOT_DIR}/upgrade/pipeline-templates/coa-upgrade-pipeline/coa-upgrade-pipeline-tpl.yml

${RM_CMD} ${ROOT_DIR}/upgrade/pipeline-templates/v42-pre-requisite-pipeline.yml

${RM_CMD} ${ROOT_DIR}/upgrade/pipeline-templates/version-upgrade-pipeline/version-upgrade-pipeline-tpl.yml

${RM_CMD} ${ROOT_DIR}/upgrade/pipelines/upgrade-pipeline.yml

${RM_CMD} ${ROOT_DIR}/upgrade/releases/v44.0.0/10-pre-upgrade/01-setup-ops-cf-apps.rb

${RM_CMD} ${ROOT_DIR}/upgrade/releases/v50.0.0/10-pre-upgrade/02-feature-initial-k8s-connectivity.rb

${RM_CMD} ${ROOT_DIR}/zz-docs/release-notes/V??_?_?.md

echo "Done"
