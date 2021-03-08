**legend:**

**X**: supported and required.  
**(X)**: supported, optional.  
**N/A**: not supported, should not be activated.

**COA available profiles**

| profile | description |
| ---------- | --------- |
| 10-embedded-cfcr-k8s    | use embeded cfcr as K8S   |
| 10-external-hws-cce-k8s | use external cfcr as K8S  |
| 10-metalikaas-k8s       | use metalikaas as K8S     |
| 60-enable-backups | activate platform backups |
| 70-alertmanager-mattermost | activate alertmanager notifications with mattermost |
| 70-alertmanager-sachet | activate alertmanager notifications with sachet saas |
| 70-enable-bi-cdc-event-infra| activate kafka cdc for bi |
| 80-r2-openstack-hws     | multi-region, R2 activation with openstack Iaas |
| 80-r2-vsphere           | multi-region, R2 activation with vpshere Iaas |
| 81-r3-openstack-hws     | multi-region, R3 activation with openstack Iaas |
| 81-r3-vsphere           | multi-region, R3 activation with vsphere Iaas |
| 90-vpn-traffic-limitation | limit vpn traffic, for non prod environments |
| 90-weave-scope          | Bosh Weave Scope troubleshooting instrumentation |
| 99-debug-coab-depls     | enable debug mode on bosh |
| 99-debug-master-depls   | enable debug mode on bosh |
| 99-debug-ops-depls      | enable debug mode on bosh |
| 99-debug-remote-r2-depls| enable debug mode on bosh |
| 99-debug-remote-r3-depls| enable debug mode on bosh |



**micro-depls**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
|00-core-connectivity-k8s| X | X |
|00-core-connectivity-terraform| X | X |
|00-gitops-management| X | X |
|bosh-master| X | X |
|concourse| X | X |
|credhub-ha| X | X |
|credhub-seeder| X | X |
|dns-recursor| X | X |
|docker-bosh-cli| X | X |
|gitlab| X | X |
|internet-proxy| X | X |
|jcr| X | X |
|minio-private-s3| X | X |
|prometheus-exporter-master| X | X |

**master-depls**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| bosh-coab| X |X |
| bosh-ops| X | X |
| bosh-remote-r2| (X) | X |
| bosh-remote-r3| (X) | X |
| cached-buildpack-pipeline| X | X |
| cf| X |X |
| cf-autoscaler| X | (X) |
| cf-internet-rps| X | N/A | 
| cloudfoundry-datastores | X |X|
| external-saas-relay | (X) | N/A |
| intranet-interco-relay | X |X |
| isolation-segment-internal | X | X |
| isolation-segment-internet | X | N/A |
| isolation-segment-intranet-1 | X | X |
| isolation-segment-intranet-2 | X | N/A |
| logsearch | X | (X) |
| logsearch-ops | X | X |
| metabase | X | X |
| openldap | X | X |
| ops-routing | X |X |
| osb-routing | X | X |
| prometheus | X | X |
| prometheus-exporter-coab | X  | X |
| prometheus-exporter-ops | X  |X  |
| r1-vpn | (X)  |(X)  |
| rundeck | (X)  |(X)  |
| shieldv8 | X | X |
| vpn-interco | (X)  | (X) |
| weave-scope | X |X |

**ops-depls**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| cf-redis-osb | (X) | (X) |
| cf-redis | (X) | N/A |
| cf-rabbit37 | X | X |
| cf-rabbit-osb| X | X |
| cloudfoundry-mysql-osb | (X) | (X) |
| cloudfoundry-mysql | (X) | N/A |
| mongodb | (X) | N/A |
| mongodb-osb | X | X |
| memcache | (X) | N/A |
| kafka | (X) | N/A |
| io-bench | (X) | (X) |
| vault | (X) | N/A |
| postgresql-docker | (X) | N/A |

**cf_apps**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| admin-ui | X | X |
| app-sso-sample | (X) | N/A |
| cf-autoscaler-sample-app | X |(X) |
| cf-networking-sample-app | X | N/A  |
| cloudflare-broker | (X) | N/A  |
| db-dumper | (X) |(X) |
| elpaaso-sandbox | (X) | N/A |
| fpv-intranet-sec-broker | X | N/A |
| intranet-sec-broker | X | X |
| huawei-cloud-osb | X |N/A |
| huawei-cloud-osb-sample-app | X |N/A |
| matomo-brokers | (X) | (X) | 
| osb-cmdb-broker-0 | (X) | X |
| osb-cmdb-broker-1 | (X) | X |
| osb-cmdb-broker-2 | (X) | X |
| osb-cmdb-broker-3 | (X) | X |
| osb-cmdb-broker-4 | (X) | X |
| osb-cmdb-broker | (X) | N/A |
| osb-reverse-proxy | (X) | (X) |
| osb-reverse-proxy-1 | (X) | (X) |
| overview-broker | (X) | (X) |
| postgresql-docker-broker | X | N/A |
| postgresql-docker-test-app | X | N/A |
| probe-internet | X | N/A |
| probe-intranet | X |(X) |
| pwm | X | (X) |
| sample-apps | (X) |(X) |
| sec-group-broker-filter-cf | X | N/A |
| smtp-sec-broker | X |(X) |
| stratos-ui-v2 | N/A | N/A |
| users-portal | (X) | N/A |

**coab**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| cf-mysql  | X | X |
| 01-cf-mysql-extended  | X | X |
| cf-rabbit  | N/A | X |
| mongodb  | X | X |
| noop  | (X) | (X) |
| redis  | X | X |
| 02-redis-extended | X | X |

**coab_cf_apps**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| coa-cf-mysql-broker  | X | X |
| coa-cf-mysql-extended-broker  | X | X |
| coa-cf-rabbit-broker  | N/A | X |
| coa-mongodb-broker  | X | X|
| coa-noop-broker  | (X) | (X) |
| coa-redis-broker  | X | X |
| coa-redis-extended-broker | X | X |

**remote-r2**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| 00-bootstrap  | X | N/A |

**remote-r3**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| 00-bootstrap  | X | N/A |

**concourse_pipelines**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| master-depls/cached-buildpack-pipeline | X | X |
| micro-depls/release-mgmt-github | N/A | N/A |
| ops-depls/recurrent-tasks | X | N/A |
| coab-depls/model-migration-pipeline | X | X |
