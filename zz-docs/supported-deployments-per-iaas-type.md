legend:

X: supported and required.
(X): supported, optional.
N/A: not supported, should not be activated.


__micro-depls__

| deployment| openstack | vsphere |
| --------- | ------ |------ |
| bosh-master| X |X |
| cfcr | X | X |
| cfcr-addon | X | X |
| cfcr-persistent-worker | X | X |
| concourse| X |X |
| credhub-ha| X |X |
| credhub-seeder| X |X |
| dns-recursor| X |X |
| docker-bosh-cli| X |X |
| gitlab| X |X |
| internet-proxy| X |X |
| internet-relay| X | N/A |
| minio-private-s3| X |X |
| nexus| X |X |
| ntp| N/A | N/A |
| prometheus-exporter-master| X |X |




__master-depls__

| deployment| openstack | vsphere |
| --------- | ------ |------ |
| bosh-coab| X |X |
| bosh-kubo| (X)  | N/A |
| bosh-ops| X | X |
| cached-buildpack-pipeline| X | X |
| cf| X |X |
| cf-autoscaler| X | (X) |
| cf-internet-rps| X | N/A |
| cfcr | X | X |
| cfcr-addon | X | X |
| cfcr-persistent-worker | X | X |
| cloudfoundry-datastores | X |X|
| intranet-interco-relay | X |X |
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
| prometheus-exporter-kubo | N/A | N/A |
| prometheus-exporter-ops | X  |X  |
| shield | (X) | (X) |
| shieldv8 | X | X |
| vpn-interco | (X)  | (X) |
| weave-scope | X |X |


__ops-depls__

| deployment| openstack | vsphere |
| --------- | ------ |------ |
| cassandra | X | N/A |
| admin-ui | N/A | N/A |
| cf-redis-osb | (X) | (X) |
| cf-redis | (X) | N/A |
| cf-rabbit | (X) | N/A |
| cf-rabbit37 | X | X |
| cloudfoundry-mysql-osb | (X) | (X) |
| cloudfoundry-mysql | (X) | N/A |
| guardian-uaa-prod | (X) | N/A |
| guardian-uaa | (X) | N/A |
| neo4j-docker | (X) | N/A |
| mongodb | (X) | N/A |
| memcache | (X) | N/A |
| kafka | (X) | N/A |
| io-bench | (X) | (X) |
| vault | (X) | N/A |
| postgresql-docker | (X) | N/A |
| nfs-volume | (X) | N/A |


__cf_apps__

| deployment| openstack | vsphere |
| --------- | ------ |------ |
| admin-ui | X | X |
| app-sso-sample | (X) | N/A |
| app-with-metrics-influxdb | N/A | N/A |
| cf-autoscaler-sample-app | X |(X) |
| cf-networking-sample-app | X | N/A  |
| cf-webui | N/A  | N/A  |
| cloudflare-broker | (X) | N/A  |
| db-dumper | (X) |(X) |
| elpaaso-sandbox | (X) | N/A |
| fpv-intranet-sec-broker | X | N/A |
| intranet-sec-broker | X | X |
| guardian-uaa-broker-cf | X |N/A |
| huawei-cloud-osb | X |N/A |
| huawei-cloud-osb-sample-app | X |N/A |
| postgresql-docker-broker | X | N/A |
| postgresql-docker-test-app | X | N/A |
| probe-internet | X | N/A |
| probe-intranet | X |(X) |
| pwm | X | (X) |
| sample-apps | (X) |(X) |
| sec-group-broker-filter-cf | X | N/A |
| smtp-sec-broker | X |(X) |
| stratos-ui-v2 | X | X |
| subdomain-resa | (X) | N/A |
| users-portal | (X) | N/A |


__coab__


| deployment| openstack | vsphere |
| --------- | ------ |------ |
| cassandra  | X | N/A |
| cf-mysql  | X | (X) |
| cf-rabbit  | N/A | N/A |
| mongodb  | X | (X) |
| noop  | (X) | (X) |
| redis  | X | N/A |
| shield  | (X) | N/A |

__coab_cf_apps__

| deployment| openstack | vsphere |
| --------- | ------ |------ |
| coa-cassandra-broker  | X | N/A |
| coa-cf-mysql-broker  | X | (X) |
| coa-cf-rabbit-broker  | N/A | N/A |
| coa-mongodb-broker  | X | (X)|
| coa-noop-broker  | (X) | (X) |
| coa-redis-broker  | X | N/A |


__concourse_pipelines__

| deployment| openstack | vsphere |
| --------- | ------ |------ |
| ops-depls/recurrent-tasks | X | N/A |
| master-depls/cached-buildpack-pipeline | X | X |
| kubo-depls/helm-provisioning-pipeline | N/A | N/A |



__kubo_deployment__

| deployment| openstack | vsphere |
| --------- | ------ |------ |
| bui | X | N/A |
| cfcr | X | N/A |
| cfcr-addon | X | N/A |
| cfcr-addon-experimental | X | N/A |
| xxx | X | N/A |
| xxx | X | N/A |

