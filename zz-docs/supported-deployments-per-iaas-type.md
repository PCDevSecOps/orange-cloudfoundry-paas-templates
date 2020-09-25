**legend:**

**X**: supported and required.  
**(X)**: supported, optional.  
**N/A**: not supported, should not be activated.

**COA available profiles**

| profile | description |
| ---------- | --------- |
| 70-alertmanager-mattermost | activate alertmanager notifications with mattermost |
| 70-alertmanager-sachet | activate alertmanager notifications with sachet saas |
| 80-r2-openstack-hws     | multi-region, R2 activation with openstack Iaas |
| 81-r3-openstack-hws     | multi-region, R3 activation with openstack Iaas |
| 80-r2-vsphere           | multi-region, R2 activation with vpshere Iaas |
| 81-r3-vsphere           | multi-region, R3 activation with vsphere Iaas |
| 90-weave-scope          | Bosh Weave Scope troubleshooting instrumentation |
| 90-vpn-traffic-limitation | limit vpn traffic, for non prod environments |
| 99-debug-master-depls   | enable debug mode on bosh |
| 99-debug-ops-depls      | enable debug mode on bosh |
| 99-debug-coab-depls     | enable debug mode on bosh |
| 99-debug-kubo-depls)    | enable debug mode on bosh |
| 99-debug-remote-r2-depls| enable debug mode on bosh |
| 99-debug-remote-r3-depls| enable debug mode on bosh |
| 10-embedded-cfcr-k8s    | use embeded cfcr as K8S   |
| 10-external-hws-cce-k8s | use external cfcr as K8S  |
| 10-metalikaas-k8s       | use metalikaas as K8S     |

**micro-depls**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| bosh-master| X |X |
| cfcr | X | X |
| cfcr-addon | N/A | N/A |
| cfcr-persistent-worker | N/A | N/A |
| concourse| X |X |
| credhub-ha| X |X |
| credhub-seeder| X |X |
| dns-recursor| X |X |
| docker-bosh-cli| X |X |
| gitlab| X |X |
| internet-proxy| X |X |
| internet-relay| X | N/A |
| jcr| X |X |
| k8s-addon| X |X |
| k8s-logging| X |X |
| k8s-prometheus| X | X |
| k8s-jaeger| X |X |
| k8s-traefik| X |X |
| k8s-concourse| N/A | N/A |
| k8s-gitlab| N/A | N/A |
| minio-private-s3| X |X |
| nexus| X |X |
| prometheus-exporter-master| X |X |

**master-depls**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| bosh-coab| X |X |
| bosh-kubo| (X)  | N/A |
| bosh-ops| X | X |
| bosh-remote-r2| (X) | N/A |
| bosh-remote-r3| (X) | N/A |
| cached-buildpack-pipeline| X | X |
| cf| X |X |
| cf-autoscaler| X | (X) |
| cf-internet-rps| X | N/A |
| cfcr | X | X |
| cfcr-addon | N/A| N/A |
| cfcr-persistent-worker | N/A | N/A |
| cloudfoundry-datastores | X |X|
| intranet-interco-relay | X |X |
| isolation-segment-internal | X | X |
| isolation-segment-internet | X | N/A |
| isolation-segment-intranet-1 | X | X |
| isolation-segment-intranet-2 | X | N/A |
| k8s-addon| X |X |
| k8s-logging| X |X |
| k8s-prometheus| X |X |
| k8s-traefik| X |X |
| k8s-jaeger| X |X |
| k8s-grafana| X |X |
| k8s-metabase| X | X |
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
| r1-vpn | (X)  |(X)  |
| shield | N/A | N/A |
| shieldv8 | X | X |
| vpn-interco | (X)  | (X) |
| weave-scope | X |X |

**ops-depls**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| cassandra | X | N/A |
| admin-ui | N/A | N/A |
| cf-redis-osb | (X) | (X) |
| cf-redis | (X) | N/A |
| cf-rabbit | N/A | N/A |
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

**cf_apps**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
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
| osb-cmdb-broker-0 | (X) | X |
| osb-cmdb-broker-1 | (X) | X |
| osb-cmdb-broker-2 | (X) | X |
| osb-cmdb-broker-3 | (X) | X |
| osb-cmdb-broker-4 | (X) | X |
| osb-cmdb-broker | (X) | X |
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

**coab**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| bui  | N/A | N/A |
| cassandra  | X | N/A |
| cf-mysql  | X | X |
| cf-rabbit  | N/A | X |
| mongodb  | X | X |
| noop  | (X) | (X) |
| redis  | X | X |
| shield  | N/A | N/A |
| 10-cfcr  | (X) | N/A |
| 10-k8s-addon  | (X) | N/A |
| 10-k8s-jaeger  | (X) | N/A |
| 10-k8s-traefik  | (X) | N/A |
| 10-k8s-prometheus  | (X) | N/A |
| 10-k8s-logging  | (X) | N/A |

**coab_cf_apps**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| coa-cassandra-broker  | X | N/A |
| coa-cf-mysql-broker  | X | X |
| coa-cf-rabbit-broker  | N/A | X |
| coa-mongodb-broker  | X | X|
| coa-noop-broker  | (X) | (X) |
| coa-redis-broker  | X | X |

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
| kubo-depls/helm-provisioning-pipeline | N/A | N/A |
| master-depls/cached-buildpack-pipeline | X | X |
| micro-depls/release-mgmt | N/A | N/A |
| ops-depls/recurrent-tasks | X | N/A |

**kubo_deployment**

| deployment | openstack | vsphere |
| ---------- | --------- | ------- |
| bui | X | N/A |
| cfcr | N/A | N/A |
| cfcr-addon | N/A | N/A |
| cfcr-addon-experimental | N/A | N/A |