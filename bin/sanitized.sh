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
    FILE_PATH="$1"
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
}

function dry_run(){
    FILE_PATH="$1"
    if [ ! -f ${FILE_PATH} ]; then
        echo "Please update sanitized.sh: asked to delete a file which is now missing: ${FILE_PATH}"
        #Once we merge the feature-automated-sanitize branch into develop then fail fast
        #For now the same sanitized.sh file is used for cleaning both develop and wip-merged... branches
        #exit 1
    else
        echo "Will remove: ${FILE_PATH}"
    fi
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



${RM_CMD} ${ROOT_DIR}/bootstrap/inception/template/inception-tpl.yml
${RM_CMD} ${ROOT_DIR}/bootstrap/inception/template/openstack-hws/tpl-bootstrap-vars.yml
${RM_CMD} ${ROOT_DIR}/bootstrap/inception/template/vsphere/tpl-bootstrap-vars.yml
${RM_CMD} ${ROOT_DIR}/bootstrap/README_BRMC.md
${RM_CMD} ${ROOT_DIR}/bootstrap/README_FE.md
${RM_CMD} ${ROOT_DIR}/bootstrap/tools/create-inception.sh



${RM_CMD} ${ROOT_DIR}/cloudflare-depls/terraform-config/spec/cloudfoundry-provider.tf



${RM_CMD} ${ROOT_DIR}/coab-depls/cassandra/template/01-operator-cf-service-broker-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cassandra/template/40-enable-prometheus-exporter-operators-2-DISABLED.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cassandra/template/51-enable-shieldv8-shield-core-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cassandra/template/52-enable-shieldv8-shield-cassandra-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cassandra/template/cassandra-vars_cassandra-ondemand-plan.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cassandra/template/cassandra-vars_plan-coab-cassandra-large.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cassandra/template/cassandra-vars_plan-coab-cassandra-medium.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cassandra/template/cassandra-vars_plan-coab-cassandra-xlarge.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cassandra/template/post-deploy.sh
${RM_CMD} ${ROOT_DIR}/coab-depls/cassandra/template/shield-vars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cassandra-broker/install/2_coab-depls-pipelines/credentials-coab-depls-bosh-pipeline.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cassandra-broker/install/2_coab-depls-pipelines/credentials-coab-depls-pipeline.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cassandra-broker/install/3_coab-network-terraform/coab-depls/terraform-config/s/s.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cassandra-broker/install/5_coab-cfapp-deployment/coa-cassandra-broker/disable-cf-app.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cassandra-broker/install/5_coab-cfapp-deployment/coa-cassandra-broker/s/s.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cassandra-broker/install/releasenote.md
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-broker/install/2_coab-cfapp-deployment/coa-cf-mysql-broker/disable-cf-app.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-broker/install/2_coab-cfapp-deployment/coa-cf-mysql-broker/s/s.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-broker/install/releasenote.md
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-broker/template/broker-catalog-config-tpl.yml # supportUrl points to CAPI intranet url
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-broker/template/coa-cf-mysql-broker_manifest-tpl.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-mongodb-broker/install/2_coab-cfapp-deployment/coa-mongodb-broker/disable-cf-app.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-mongodb-broker/install/2_coab-cfapp-deployment/coa-mongodb-broker/s/s.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-mongodb-broker/install/releasenote.md
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-mongodb-broker/template/coa-mongodb-broker_manifest-tpl.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-noop-broker/template/coa-noop-broker_manifest-tpl.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-broker/install/2_coab-cfapp-deployment/coa-redis-broker/disable-cf-app.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-broker/install/2_coab-cfapp-deployment/coa-redis-broker/s/s.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-broker/install/releasenote.md
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-broker/template/coa-redis-broker_manifest-tpl.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/02-operator-add-broker-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/30-context-patch-broker-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/40-enable-prometheus-exporter-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/71-enable-shieldv8-shield-core-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/72-enable-shieldv8-shield-cf-mysql-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/cf-mysql-vars_plan-coab-mariadb-capacitylarge.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/cf-mysql-vars_plan-coab-mariadb-large.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/cf-mysql-vars_plan-coab-mariadb-medium.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/cf-mysql-vars_plan-coab-mariadb-powerlarge.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/cf-mysql-vars_plan-coab-mariadb-small.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/cf-mysql-vars_plan-coab-mariadb-xlarge.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/cf-mysql-vars_plan-coab-mariadb-xxlarge.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/post-deploy.sh
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/shield-vars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/01-enable-mongodb-broker-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/02-enable-mongodb-broker-smoke-tests-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/40-enable-prometheus-exporter-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/42-enable-shieldv8-standalone-operators-DISABLED.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/71-enable-shieldv8-shield-core-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/71-enable-shieldv8-shield-core-operators-COLOCATED.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/71-enable-shieldv8-shield-core-operators-STANDALONEAPI.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/71-enable-shieldv8-shield-core-operators-STANDALONEOPS.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/72-enable-shieldv8-shield-mongod-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/mongodb.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/post-deploy.sh
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/shield-vars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-rabbit/template/cf-rabbitmq-37-vars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-rabbit/template/shield-vars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/redis/template/01-operator-cf-service-broker-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/redis/template/post-deploy.sh
${RM_CMD} ${ROOT_DIR}/coab-depls/redis/template/redis-vars_plan-coab-redis-small.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/shield/template/1-context-patch-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/shield/template/shield-vars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/spec/cassandra-service-broker.tf
${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/spec/cf-mysql-service-broker.tf
${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/spec/cf-rabbit-service-broker.tf
${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/spec/cloudfoundry.tf
${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/spec/mongodb-service-broker.tf
${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/spec/noop-service-broker.tf
${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/spec/redis-service-broker.tf
${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/template/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/master-depls/bosh-coab/template/2-config-server-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/bosh-coab/template/2-hm-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/bosh-ops/template/2-config-server-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/bosh-ops/template/2-hm-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/cached-buildpack-pipeline/concourse-pipeline-config/pipeline-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/master-depls/cached-offline-inet-resources-pipeline/concourse-pipeline-config/pipeline-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/master-depls/cf/template/3-custom-uaa-clients-autoscaler-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/cf-autoscaler/template/1-shield-backup-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/cf-autoscaler/template/cf-autoscaler.yml
${RM_CMD} ${ROOT_DIR}/master-depls/cfcr/template/cfcr-vars.yml
${RM_CMD} ${ROOT_DIR}/master-depls/cloudfoundry-datastores/template/migration/blobstore-synchro.sh
${RM_CMD} ${ROOT_DIR}/master-depls/cloudfoundry-datastores/template/migration/get-rabbit-vhosts.py
${RM_CMD} ${ROOT_DIR}/master-depls/logsearch/template/firehose-uaa-client-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/logsearch-ops/template/8-add-oauth2-proxy-bosh-release-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/logsearch-ops/template/8-add-oauth2-proxy-operators.yml.DISABLED
${RM_CMD} ${ROOT_DIR}/master-depls/logsearch-ops/template/logsearch-ops-tpl.yml
${RM_CMD} ${ROOT_DIR}/master-depls/metabase/template/70-enable-bi-cdc-event-infra/3-kafka-bi-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/metabase/template/70-enable-bi-cdc-event-infra/6-add-yugabyte-oauth2-proxy-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/openldap/doc/Readme.md
${RM_CMD} ${ROOT_DIR}/master-depls/openstack-validator-pipeline/concourse-pipeline-config/pipeline-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/master-depls/ops-routing/template/2-ops-uaa-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/peripli-osb/template/2-cf-sm-proxy-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus/template/4-enable-grafana-ldap-access-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus/template/5-scrape-credhub-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus/template/prometheus-tpl.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus/template/terraform-vars.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus-exporter-coab/template/2-context-patch-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus-exporter-coab/template/4-enable-grafana-ldap-access-operators-DISABLED.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus-exporter-coab/template/prometheus-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus-exporter-kubo/template/prometheus-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus-exporter-ops/template/1-bosh-exporter-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus-exporter-ops/template/openstack-hws/1-cf-exporter-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus-exporter-ops/template/openstack-hws/1-firehose-exporter-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/template/vsphere/2-bosh-dns-aliases-runtime-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/terraform-config/spec-openstack-hws/cf-provider.tf
${RM_CMD} ${ROOT_DIR}/master-depls/terraform-config/spec-openstack-hws/service-broker-autoscaler.tf
${RM_CMD} ${ROOT_DIR}/master-depls/terraform-config/template/openstack-hws/terraform-tpl.tfvars.yml
${RM_CMD} ${ROOT_DIR}/master-depls/terraform-config/template/terraform-tpl.tfvars.yml

${RM_CMD} ${ROOT_DIR}/micro-depls/auto-sanitize/concourse-pipeline-config/auto-sanitize.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/bosh-master/template/2-config-server-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/bosh-master/template/2-hm-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/cfcr/template/cfcr-vars.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/concourse/template/01-add-haproxy-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/concourse/template/concourse-micro-reuse-old-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/concourse/template/ldap-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/concourse/template/openstack-hws/cf-sso-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/credhub-ha/template/1-credhub-backend-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/credhub-seeder/template/credhub-seeder-tpl.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/credhub-seeder/template/openstack-hws/credhubcli-scripting-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/credhub-seeder/template/vsphere/credhubcli-scripting-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/docker-bosh-cli/template/nginx/index-full-tpl.html
${RM_CMD} ${ROOT_DIR}/micro-depls/docker-bosh-cli/template/nginx/index-services-tpl.html
${RM_CMD} ${ROOT_DIR}/micro-depls/gitlab/template/gitlab-tpl.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/prometheus-exporter-master/template/openstack-hws/1-black-box-scrape-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/prometheus-exporter-master/template/openstack-hws/1-black-box-scrape-proxy-internet-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/prometheus-exporter-master/template/openstack-hws/1-black-box-scrape-proxy-intranet-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/prometheus-exporter-master/template/prometheus-exporter-master.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/prometheus-exporter-master/template/prometheus-exporter-master-tpl.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/template/vsphere/2-bosh-dns-aliases-runtime-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/terraform-config/spec-openstack-hws/sg-internet.tf
${RM_CMD} ${ROOT_DIR}/micro-depls/terraform-config/template/openstack-hws/terraform-tpl.tfvars.yml



${RM_CMD} ${ROOT_DIR}/ops-depls/cassandra/template/cassandra-deployment/operations/cf-service-broker.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cassandra/template/cassandra-vars.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cassandra/template/old_operators/cassandra-tpl.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/db-dumper/template/db-dumper_manifest-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/db-dumper/template/post-deploy.sh
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/elpaaso-sandbox/doc/readme.md

${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/huawei-cloud-osb/template/config-json-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/huawei-cloud-osb-sample-app/template/pre-cf-push.sh
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/matomo-brokers/template/matomo-intranet-broker_manifest-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/mattermost/template/mattermost_manifest-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/ops-dataflow/template/import-streams-tasks.shell
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/ops-dataflow/template/loggregator-stream.shell
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/ops-dataflow/template/ops-dataflow_manifest-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/ops-dataflow/template/post-bosh-deploy.sh
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/ops-portal/template/index.tpl
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/postgresql-docker-broker/template/postgresql-cf-service-broker_manifest-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/postgresql-docker-test-app/template/server.js
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/users-portal/doc/readme.md
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/users-portal/template/conf/header.hbs
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/users-portal/template/conf/index.md
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/users-portal/template/conf/site.json
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/users-portal/template/pre-cf-push.sh
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-rabbit37/template/cf-rabbit37-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-rabbit37/template/openstack-hws/30-register-osbbroker-operators.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-redis/template/cf-redis-vars.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-redis-osb/template/vsphere/cf-redis-vars.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-cassandra.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-cloudflare.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-db-dumper.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-ha-internet.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-kafka.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-matomo.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-memcache.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-mongodb.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-neo4j.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-p-mysql.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-postgres-docker.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-redis-sec.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-smtp.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-uaa-guardian.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec-openstack-hws/service-broker-vault.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/template/openstack-hws/terraform-tpl.tfvars.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry-mysql/template/30-broker-patch-operators.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry-mysql/template/45-prometheus-mysqld-exporter-operators.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry-mysql/template/cloudfoundry-mysql-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry-mysql-osb/template/vsphere/cloudfoundry-mysql-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/concourse-dev/template/concourse-dev-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/concourse-dev/template/concourse-dev-tpl-old.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/concourse-dev/template/concourse-dev-vars.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/concourse-dev/template/concourse-micro-reuse-old-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/concourse-dev/template/ldap-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/kafka/template/01-add-kafka-operators.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/kafka/template/02-add-kafka-broker-operators.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/memcache/template/memcache.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/mongodb/template/mongodb.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/neo4j-docker/template/neo4j-docker-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/nfs-volume/template/nfs-volume.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/nfs-volume/template/nfs-volume-tpl.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/postgresql-docker/template/postgresql-docker.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/recurrent-tasks/concourse-pipeline-config/recurrent-tasks.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/recurrent-tasks/concourse-pipeline-config/tasks/restart-cf-apps/task.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/vault/template/safe-broker-operators.yml


${RM_CMD} ${ROOT_DIR}/upgrade/load-coa-upgrade-pipeline.sh
${RM_CMD} ${ROOT_DIR}/upgrade/load-paas-templates-upgrade-pipeline.sh
${RM_CMD} ${ROOT_DIR}/upgrade/load-prerequisite-pipeline.sh
${RM_CMD} ${ROOT_DIR}/upgrade/load-upgrade-pipeline.sh
${RM_CMD} ${ROOT_DIR}/upgrade/pipelines/upgrade-pipeline.yml
${RM_CMD} ${ROOT_DIR}/upgrade/pipeline-templates/coa-upgrade-pipeline/coa-upgrade-pipeline-tpl.yml
${RM_CMD} ${ROOT_DIR}/upgrade/pipeline-templates/v42-pre-requisite-pipeline.yml
${RM_CMD} ${ROOT_DIR}/upgrade/pipeline-templates/version-upgrade-pipeline/version-upgrade-pipeline-tpl.yml

${RM_CMD} ${ROOT_DIR}/upgrade/scripts/common.sh
${RM_CMD} ${ROOT_DIR}/zz-docs/HOW_TO.md
${RM_CMD} ${ROOT_DIR}/zz-docs/release-notes/V40_0_0.md
${RM_CMD} ${ROOT_DIR}/zz-docs/release-notes/V41_0_0.md
${RM_CMD} ${ROOT_DIR}/zz-docs/release-notes/V42_0_0.md
${RM_CMD} ${ROOT_DIR}/zz-docs/release-notes/V42_0_1.md
${RM_CMD} ${ROOT_DIR}/zz-docs/release-notes/V43_0_1.md
${RM_CMD} ${ROOT_DIR}/zz-docs/release-notes/V44_0_*.md
${RM_CMD} ${ROOT_DIR}/zz-docs/release-notes/V45_0_*.md

echo "Sanitize v44 develop"
${RM_CMD} ${ROOT_DIR}/admin/recreate-inception.sh
${RM_CMD} ${ROOT_DIR}/bootstrap/inception/template/openstack-hws/tpl-secrets.yml
${RM_CMD} ${ROOT_DIR}/bootstrap/inception/template/vsphere/tpl-secrets.yml
${RM_CMD} ${ROOT_DIR}/bootstrap/micro-bosh/template/micro-bosh-operators.yml
${RM_CMD} ${ROOT_DIR}/bootstrap/tools/configure-openstack.sh
${RM_CMD} ${ROOT_DIR}/bootstrap/tools/functions.sh
${RM_CMD} ${ROOT_DIR}/cloudflare-depls/terraform-config/README
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-rabbit-broker/install/2_coab-cfapp-deployment/coa-cf-rabbit-broker/disable-cf-app.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-rabbit-broker/install/2_coab-cfapp-deployment/coa-cf-rabbit-broker/s/s.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-rabbit-broker/install/releasenote.md
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-mongodb-broker/template/broker-catalog-config-tpl.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-redis-broker/template/broker-catalog-config-tpl.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/common-broker-scripts/post-deploy.sh
${RM_CMD} ${ROOT_DIR}/micro-depls/concourse/bootstrap/bootstrap-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/bosh/2-config-server-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/bosh/2-hm-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/cfcr-core-addon-products/06-falco-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/cfcr-core-addon-products/06-fluentd-elasticsearch-operators.yml
${RM_CMD} ${ROOT_DIR}/upgrade/lib/upgrade/cf_app_deployment.rb
${RM_CMD} ${ROOT_DIR}/upgrade/releases/v42.0.0/10-pre-upgrade/01-upgrade.rb

${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/template/openstack-hws/terraform-tpl.tfvars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/template/vsphere/terraform-tpl.tfvars.yml
${RM_CMD} ${ROOT_DIR}/master-depls/shieldv8/template/custom-shieldv8-vars.yml
${RM_CMD} ${ROOT_DIR}/master-depls/terraform-config/template/vsphere/terraform-tpl.tfvars.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/credhub-seeder/template/credhubcli-scripting-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/terraform-config/template/vsphere/terraform-tpl.tfvars.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec/service-broker-intranet-proxy.tf
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/template/vsphere/terraform-tpl.tfvars.yml
${RM_CMD} ${ROOT_DIR}/upgrade/releases/v44.0.0/10-pre-upgrade/01-setup-ops-cf-apps.rb
${RM_CMD} ${ROOT_DIR}/coab-depls/redis/template/01-operator-cf-service-broker-operators_plan-coab-redis-sentinelsmall.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/redis/template/01-operator-cf-service-broker-operators_plan-coab-redis-small.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cloudfoundry/terraform-config/spec/cloudfoundry.tf
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus-exporter-ops/template/1-cf-exporter-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus-exporter-ops/template/1-firehose-exporter-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/shieldv8/template/1-context-patch-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/terraform-config/spec/cf-provider.tf



echo "Sanitize v44 WIP"
${RM_CMD} ${ROOT_DIR}/coab-depls/postgresql/template/01-chart-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/cf/template/openstack-hws/8-add-sandbox-pause-cron-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/metabase/template/2-shieldv8-backup-operators-DISABLED.yml
${RM_CMD} ${ROOT_DIR}/master-depls/shieldv8/template/shieldv8-vars.yml
${RM_CMD} ${ROOT_DIR}/master-depls/terraform-config/spec-openstack-hws/cf-service-broker-autoscaler.tf
${RM_CMD} ${ROOT_DIR}/micro-depls/coa-upgrade/concourse-pipeline-config/coa-upgrade.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/status-page-connector/template/pre-cf-push.sh
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-apps-deployments/status-page-connector/template/status-page-connector_manifest-tpl.yml

echo "Sanitize v45 develop"
${RM_CMD} ${ROOT_DIR}/master-depls/shieldv8/template/custom-shieldv8-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/gitlab/template/1-gitlab-config-scripting-operators.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-rabbit37/template/custom-shieldv8-vars.yml
${RM_CMD} ${ROOT_DIR}/ops-depls/cf-redis/template/10-enable-prometheus-exporter-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/shield/add-shield-import-members-errand-operators.yml

echo "Sanitize v46 develop"
${RM_CMD} ${ROOT_DIR}/admin/check-certs-expiry.sh
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/cf-mysql-vars_plan-coab-mariadb-medium-big-request.yml
${RM_CMD} ${ROOT_DIR}/master-depls/k8s-grafana/template/27-grafana-ldap-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/k8s-grafana/template/27-grafana-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/k8s-harbor/template/1-harbor-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/k8s-harbor/template/2-harbor-postgresql-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/k8s-metabase/template/3-metabase-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/k8s-metabase/template/4-metabase-postgresql-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/k8s-shield/template/22-shield-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/shieldv8/template/09-add-shield-import-system-bbr-deployment-cfcr-micro-errand-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/shieldv8/template/09-add-shield-import-system-bbr-deployment-master-depls-errand-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/shieldv8/template/09-add-shield-import-system-bbr-deployment-micro-depls-errand-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/shieldv8/template/09-add-shield-import-system-bbr-director-bosh-micro-errand-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/jcr/template/jcr-config-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-concourse/template/22-concourse-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-concourse/template/22-concourse-postgresql-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-concourse/template/2-concourse-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-concourse/template/3-concourse-postgresql-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-gitlab/template/23-gitlab-cert-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-gitlab/template/23-gitlab-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-gitlab/template/23-gitlab-postgresql-stolon-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-gitlab/template/2-gitlab-cert-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-gitlab/template/7-gitlab-operators.yml
${RM_CMD} ${ROOT_DIR}/micro-depls/k8s-gitlab/template/9-gitlab-postgresql-stolon-operators.yml
${RM_CMD} ${ROOT_DIR}/remote-r2-depls/00-bootstrap/template/99-debug-remote-r2-depls/99-debug-password-operators.yml
${RM_CMD} ${ROOT_DIR}/remote-r2-depls/template/cloud-config-tpl.yml
${RM_CMD} ${ROOT_DIR}/remote-r2-depls/terraform-config/template/80-r2-openstack-hws/terraform-tpl.tfvars.yml
${RM_CMD} ${ROOT_DIR}/remote-r2-depls/terraform-config/template/80-r2-vsphere/terraform-tpl.tfvars.yml
${RM_CMD} ${ROOT_DIR}/remote-r3-depls/00-bootstrap/template/99-debug-remote-r3-depls/99-debug-password-operators.yml
${RM_CMD} ${ROOT_DIR}/remote-r3-depls/template/cloud-config-tpl.yml
${RM_CMD} ${ROOT_DIR}/remote-r3-depls/terraform-config/template/80-r2-openstack-hws/terraform-tpl.tfvars.yml
${RM_CMD} ${ROOT_DIR}/remote-r3-depls/terraform-config/template/80-r2-vsphere/terraform-tpl.tfvars.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-logging/5-falco-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-logging/6-fluentd-elasticsearch-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-traefik/8-traefik-ingressroute-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/bosh/0-debug-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/cfcr-core-addon-products/00-8-traefik-ingressroute-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/cfcr/cfcr-common-vars.yml
${RM_CMD} ${ROOT_DIR}/zz-docs/Certs_rotation.md
${RM_CMD} ${ROOT_DIR}/zz-docs/release-notes/V46_0_0.md
${RM_CMD} ${ROOT_DIR}/zz-docs/release-notes/V46_0_1.md

echo "Sanitize v47 develop"
${RM_CMD} ${ROOT_DIR}/admin/recreate-micro-bosh.sh
${RM_CMD} ${ROOT_DIR}/master-depls/shieldv8/template/09-add-shield-import-system-bbr-deployment-cfcr-coab-errand-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/shield/add-shield-import-system-bbr-deployment-master-depls-bosh-remote-r2-errand-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/shield/add-shield-import-system-bbr-deployment-master-depls-bosh-remote-r3-errand-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/cfcr/cfcr-common-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/master-depls/bosh-coab/template/80-r2-vsphere/9-http-proxy-for-vsphere-r2-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/intranet-interco-relay/template/vsphere/5-TO-REMOVE-use-r2-proxy-as-cache-peer-for-vsphere-access-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/intranet-interco-relay/template/vsphere/5-TO-REMOVE-use-r2-proxy-as-cache-peer-for-vsphere-access-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/cfcr-common-serv/10-metalikaas-k8s/cfcr-addon-serv-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/10-k8s-crunchy-osb/template/10-embedded-cfcr-k8s/pgo-osb-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/10-k8s-crunchy-osb/template/10-metalikaas-k8s/04-deployment-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-crunchy/10-metalikaas-k8s/3-jobs-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-service-catalog/10-external-hws-cce-k8s/service-catalog-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/zz-docs/release-notes/V46_0_1.md
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-weavescope/02-apply-weavescope-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s/11-flux-crd-helm-operators.yml

${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/30-context-patch-broker-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/50-enable-prometheus-exporter-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/71-add-shield-core-to-broker-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/72-add-shield-agent-to-mysql-operators.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/cf-mysql-extended-common-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/01-cf-mysql-extended/template/shield-vars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-extended-broker/install/2_coab-cfapp-deployment/coa-cf-mysql-extended-broker/disable-cf-app.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-extended-broker/install/2_coab-cfapp-deployment/coa-cf-mysql-extended-broker/s/s.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-extended-broker/install/releasenote.md
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-apps-deployments/coa-cf-mysql-extended-broker/template/broker-catalog-config-tpl.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/terraform-config/spec/cf-mysql-extended-service-broker.tf
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus/template/80-r2-openstack-hws/9-scrape-vpn-blackbox-operators.yml
${RM_CMD} ${ROOT_DIR}/master-depls/prometheus/template/80-r2-vsphere/9-scrape-vpn-blackbox-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/multi-region-common/01-cf-mysql-extended/30-context-patch-broker-operators.yml


echo "Sanitize v48 develop"
${RM_CMD} ${ROOT_DIR}/coab-depls/ops-scripts/clean_service_instance_leaks.sh
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-rabbit/template/openstack-hws/shield-vars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/openstack-hws/shield-vars.yml

${RM_CMD} ${ROOT_DIR}/admin/certs_rotation.md
${RM_CMD} ${ROOT_DIR}/admin/check-certs.sh
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/openstack-hws/shield-vars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-mysql/template/prometheus-vars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/cf-rabbit/template/openstack-hws/shield-vars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/mongodb/template/openstack-hws/shield-vars.yml
${RM_CMD} ${ROOT_DIR}/coab-depls/ops-scripts/clean_service_instance_leaks.sh
${RM_CMD} ${ROOT_DIR}/micro-depls/jcr/template/jcr-version-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-common-serv/10-metalikaas-k8s/k8s-deploy-serv-vars-tpl.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-crunchy/10-embedded-cfcr-k8s/4-configmap-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-crunchy/10-metalikaas-k8s/3-jobs-operators-deprecated.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-crunchy/10-metalikaas-k8s/4-configmap-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-falco/1-falco-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-flux/03-crd-helm-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s-logging/4-elasticsearch-operators.yml
${RM_CMD} ${ROOT_DIR}/shared-operators/k8s/03-0-control-operators.yml

${RM_CMD} ${ROOT_DIR}/ops-depls/osb-cmdb-pipeline/concourse-pipeline-config/osb-cmdb-pipeline-tpl.yml # cmdb pipeline is still experimental and need user name cleanup
${RM_CMD} ${ROOT_DIR}/ops-depls/osb-cmdb-pipeline/concourse-pipeline-config/pipeline-vars-tpl.yml # cmdb pipeline is still experimental and need user name cleanup

${RM_CMD} ${ROOT_DIR}/shared-operators/bosh/9-clean-bosh-directors-tasks-operators.yml
echo "Done"
