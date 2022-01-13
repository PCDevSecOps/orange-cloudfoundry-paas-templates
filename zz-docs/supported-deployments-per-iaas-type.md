## COA available profiles

| profile                       | description |
| ----------------------------- | ----------- |
| 60-enable-backups             | enable platform backups |
| 70-alertmanager-mattermost    | enable alertmanager notifications with mattermost |
| 70-alertmanager-sachet        | enable alertmanager notifications with sachet saas |
| 70-enable-bi-cdc-event-infra  | enable kafka cdc for bi |
| 80-r2-openstack-hws           | multi-region, R2 activation with openstack Iaas |
| 80-r2-vsphere                 | multi-region, R2 activation with vpshere Iaas |
| 81-r3-openstack-hws           | multi-region, R3 activation with openstack Iaas |
| 81-r3-vsphere                 | multi-region, R3 activation with vsphere Iaas |
| 90-vpn-traffic-limitation     | limit vpn traffic, for non prod environments |
| 90-weave-scope                | Bosh Weave Scope troubleshooting instrumentation |
| 99-debug-k8s-micro-depls      | enable debug mode on k8s |
| 99-debug-k8s-master-depls     | enable debug mode on k8s |
| 99-debug-k8s-ops-depls        | enable debug mode on k8s |
| 99-debug-k8s-coab-depls       | enable debug mode on k8s |
| 99-debug-remote-r2-depls      | enable debug mode on bosh |
| 99-debug-coab-depls           | enable debug mode on bosh |
| 99-debug-master-depls         | enable debug mode on bosh |
| 99-debug-ops-depls            | enable debug mode on bosh |
| 99-debug-remote-r2-depls      | enable debug mode on bosh |
| 99-debug-remote-r3-depls      | enable debug mode on bosh |

>**legend:**  
> **X**: supported and required.  
> **(X)**: supported, optional.  
> **N/A**: not supported, should not be activated.

## micro-depls

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| 00-core-connectivity-k8s        | X | X |
| 00-core-connectivity-terraform  | X | X |
| 00-gitops-management            | X | X |
| 01-ci-k8s                       | X | X |
| bosh-master                     | X | X |
| concourse                       | X | X |
| credhub-ha                      | X | X |
| credhub-seeder                  | X | X |
| dns-recursor                    | X | X |
| docker-bosh-cli                 | X | X |
| inception                       | X | X |
| internet-proxy                  | X | X |
| k8s-gitlab                      | X | X |
| k8s-jcr                         | N/A | N/A |
| k8s-minio                       | N/A | N/A | 
| k8s-openldap                    | N/A | N/A |
| k8s-traefik-core-connectivity   | N/A | N/A |
| ops-routing                     | X | X |
| prometheus-exporter-master      | X | X |

## master-depls

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| bosh-coab                     | X |X |
| bosh-ops                      | X | X |
| bosh-remote-r2                | (X) | X |
| bosh-remote-r3                | (X) | X |
| cf                            | X |X |
| cf-autoscaler                 | X | (X) |
| cf-internet-rps               | X | N/A | 
| cloudfoundry-datastores       | X |X|
| external-saas-relay           | (X) | N/A |
| intranet-interco-relay        | X |X |
| isolation-segment-internal    | X | X |
| isolation-segment-internet    | X | N/A |
| isolation-segment-intranet-1  | X | X |
| isolation-segment-intranet-2  | X | N/A |
| logsearch                     | X | (X) |
| logsearch-ops                 | X | X |
| metabase                      | X | X |
| prometheus                    | X | X |
| prometheus-exporter-coab      | X | X |
| prometheus-exporter-ops       | X |X  |
| r1-vpn                        | (X) | (X) |
| shieldv8                      | X | X |
| weave-scope                   | X |X |

## ops-depls

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| cf-redis-osb            | (X) | (X) |
| cf-rabbit-osb           | X | X |
| cloudfoundry-mysql-osb  | (X) | (X) |
| io-bench                | (X) | (X) |
| mongodb-osb             | X | X |

## cf_apps

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| admin-ui                      | X | X |
| cf-autoscaler-sample-app      | X |(X) |
| cf-networking-sample-backend  | X | N/A  |
| cf-networking-sample-frontend | X | N/A  |
| huawei-cloud-osb              | X |N/A |
| huawei-cloud-osb-sample-app   | X |N/A |
| internet-broker               | X | N/A |
| internet-sec-broker           | X | N/A |
| intranet-proxy-broker         | X | X |
| intranet-proxy-sec-broker     | X | X |
| matomo-brokers                | (X) | (X) | 
| osb-cmdb-broker-0             | (X) | X |
| osb-cmdb-broker-1             | (X) | X |
| osb-cmdb-broker-2             | (X) | X |
| osb-cmdb-broker-3             | (X) | X |
| osb-cmdb-broker-4             | (X) | X |
| osb-cmdb-broker               | (X) | N/A |
| osb-reverse-proxy             | (X) | (X) |
| osb-reverse-proxy-1           | (X) | (X) |
| overview-broker               | (X) | (X) |
| probe-internet                | X | N/A |
| probe-intranet                | X |(X) |
| sample-apps                   | (X) |(X) |
| sec-group-broker-filter-cf    | X | N/A |
| smtp-sec-broker               | X |(X) |

## coab-depls

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| 01-cf-mysql-extended  | X | X |
| 02-redis-extended     | X | X |
| 03-cf-rabbit-extended | X | X |
| 04-mongodb-extended   | X | X |
| 20-strimzi-kafka      | X | X |
| cf-mysql              | X | X |
| cf-rabbit             | N/A | X |
| mongodb               | X | X |
| noop                  | (X) | (X) |
| redis                 | X | X |
| redis                 | X | X |
| vpn-probe             | X | X |



## coab_cf_apps

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| coa-cf-mysql-broker           | X | X |
| coa-cf-mysql-extended-broker  | X | X |
| coa-cf-rabbit-broker          | N/A | X |
| coa-cf-rabbit-extended-broker          | N/A | X |
| coa-mongodb-broker            | X | X|
| coa-mongodb-extended-broker            | X | X|
| coa-noop-broker               | (X) | (X) |
| coa-redis-broker              | X | X |
| coa-redis-extended-broker     | X | X |

## remote-r2-depls

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| 00-bootstrap | X | N/A |

## remote-r3-depls

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| 00-bootstrap | X | N/A |

## concourse_pipelines

| pipeline | openstack | vsphere |
| ---------- | --------- | ------- |
| main/master-depls-cached-buildpack-pipeline   | X | X |
| main/ops-depls-recurrent-tasks                | X | X |
| main/micro-depls-retrigger-all-deployments    | X | X |
| main/coab-depls-model-migration-pipeline      | X | X |
| main/micro-depls-release-mgmt-github          | N/A | N/A |
