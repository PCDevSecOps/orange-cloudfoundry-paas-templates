## shield v8 readme

__server implementation__

a static ip (192.168.99.26) is used
an internal alias DNS references this IP : https://shield.internal.paas
an external alias (ops-routing) references this IP : https://shieldv8-webui.((/secrets/cloudfoundry_ops_domain))
a local S3 storage is also added to the shield deployment : https://shield-s3.internal.paas

__deployment implementation__

all operators and vars files related to shield v8 are located under the directory shared-operators/shield
a submodule is also referenced in paas-templates in order to reuse the manifest given by S/W (directory submodules/shield)
all deployments (which require a backup) define an extended scan path towards the operators/vars directory : 
```yml
      templates:
        extended_scan_path:
        - shared-operators/shield

```
all deployments follow the almost the same structure concerning shieldv8 implementation based on symlinks 
```bash
tree -L 4 | grep shieldv8
```

```yml
├── common-shieldv8-vars.yml -> ../../../shared-operators/shield/shieldv8-vars.yml
├── custom-shieldv8-vars.yml
├── openstack-hws
│   └── shieldv8-proxy-internet-vars.yml -> ../../../../shared-operators/shield/shieldv8-proxy-internet-vars.yml
├── vsphere
│   └── shieldv8-proxy-intranet-vars.yml -> ../../../../shared-operators/shield/shieldv8-proxy-intranet-vars.yml
├── 2-shieldv8-adapt-operators.yml
├── 2-shieldv8-add-mc-job-operators.yml -> ../../../shared-operators/shield/add-mc-job-operators.yml
├── 2-shieldv8-add-release-minio-operators.yml -> ../../../shared-operators/shield/add-release-minio-operators.yml
├── 2-shieldv8-add-release-shield-operators.yml -> ../../../shared-operators/shield/add-release-shield-operators.yml
├── 2-shieldv8-add-shield-agent-job-operators.yml -> ../../../shared-operators/shield/add-shield-agent-job-operators.yml
├── 2-shieldv8-add-shield-agent-proxy-operators.yml -> ../../../shared-operators/shield/add-shield-agent-proxy-operators.yml
├── 2-shieldv8-add-shield-import-asystems-fs-errand-operators.yml -> ../../../shared-operators/shield/add-shield-import-systems-fs-errand-operators.yml
├── 2-shieldv8-add-shield-import-members-errand-operators.yml -> ../../../shared-operators/shield/add-shield-import-members-errand-operators.yml
├── 2-shieldv8-add-shield-import-policies-errand-operators.yml -> ../../../shared-operators/shield/add-shield-import-policies-errand-operators.yml
├── 2-shieldv8-add-shield-import-storage-errand-operators.yml -> ../../../shared-operators/shield/add-shield-import-storage-errand-operators.yml
├── 2-shieldv8-create-bucket-scripting-pre-start-only-operators.yml -> ../../../shared-operators/shield/create-bucket-scripting-pre-start-only-operators.yml
├── 2-shieldv8-unadapt-operators.yml
```
the operator called "2-shieldv8-adapt-operators" rename the instance group to shield in order that generic shield v8 operators applied
the operator called "2-shieldv8-unadapt-operators" rename the instance group to its origin name

__operators__ 

| name | description |
| --------- | ------ |
| add-mc-job-operators.yml | add mc job (from minio release) to the deployment in order to interfact with S3 backend |
| add-release-minio-operators.yml | add minio release to the deployment |
| add-release-scripting-operators.yml | add scripting release to the deployment |
| add-release-shield-operators.yml | add shield release to the deployment |
| add-shield-agent-job-operators.yml | add shield agent job to the deployment by using bosh-link |
| add-shield-agent-proxy-operators.yml | add proxy properties to the shield agent |
| add-shield-import-members-errand-operators.yml | add members information to the tenant (administrater user) |
| add-shield-import-policies-errand-operators.yml | add policies information to the tenant (4 and 21 days retentions) |
| add-shield-import-storage-errand-operators.yml | add s3 storage information to the tenant (local and remote) |
| add-shield-import-systems-cassandra2-errand-operators.yml | define tenant with cassandra system (custom cassandra plugin, not used yet) |
| add-shield-import-systems-cassandra-errand-operators.yml | define tenant with cassandra system (standard cassandra plugin) |
| add-shield-import-systems-cf-rabbit-errand-operators.yml | define tenant with cf-rabbit system (standard cf-rabbit plugin) |
| add-shield-import-systems-cf-redis-errand-operators.yml | define tenant with cf-redis system (standard cf-redis plugin) |
| add-shield-import-systems-fs-errand-operators.yml | define tenant with fs system (standard fs plugin) |
| add-shield-import-systems-mongodb-errand-operators.yml | define tenant with mongodb system (standard mongodb plugin) |
| add-shield-import-systems-mysql-errand-operators.yml | define tenant with mysql system (standard mysql plugin) |
| add-shield-import-systems-postgres-errand-operators.yml | define tenant with postgres system (standard postgres plugin) |
| add-shield-import-systems-xtrabackup-errand-operators.yml | define tenant with xtrabackup system (standard xtrabackup plugin, not used yet) |
| create-bucket-scripting-operators.yml | define scriping release job template |
| create-bucket-scripting-post-start-only-operators.yml | define bucket creation in post-start hook |
| create-bucket-scripting-pre-start-only-operators.yml | define bucket creation in pre-start hook |
| fix-shield-version-operators.yml | fix shield version (will be removed after shield v7 migration) |
| remove-shieldv8-operators.yml | remove shield v8 jobs in order to allow bootstrap |

__vars__ 

| name | description |
| --------- | ------ |
| shieldv8-proxy-internet-vars.yml | contains internet proxy endpoint |
| shieldv8-proxy-intranet-vars.yml | contains intranet proxy endpoint |
| shieldv8-vars.yml | contains common shield v8 variables (i.e : s3 information, domain, ...) |

__micro-depls backup table__

| deployment | postgres | fs | mysql  | rabbit | redis | cassandra | mongo | scripting | custo |
| ---------  | ------ |------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| bosh-master | X |   |   |   |   |   |   |  PRE | No  |
| concourse | X |   |   |   |   |   |   | PRE |  No |
| credhub-ha | X |   |   |   |   |   |   | PRE |  Yes (grab in custom-shieldv8-vars-tpl.yml) |
| gitlab |  | X  |   |   |   |   |   | POST  | Yes (additional fs system with socket exclusion) |
 
__master-depls backup table__

| deployment | postgres | fs | mysql  | rabbit | redis | cassandra | mongo | scripting | custo |
| ---------  | ------ |------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| bosh-coab | X |   |   |   |   |   |   |  PRE |  No |
| bosh-kubo | X |   |   |   |   |   |   |  PRE |  No |
| bosh-ops | X |   |   |   |   |   |   |  PRE |  No |
| cf-autoscaler | X |   |   |   |   |   |   |  PRE |  No |
| cloudfoundry-datastores | X |   | X  |   |   |   |   |  PRE | Yes (additional mysql system)|
| metabase | X |   |   |   |   |   |   |  PRE | No |
| openldap |   | X |   |   |   |   |   |  PRE | No |
| shieldv8 |   | X |   |   |   |   |   |  PRE | Yes(static ip, submodule usage, unlock) |

__ops-depls backup table__

| deployment | postgres | fs | mysql  | rabbit | redis | cassandra | mongo | scripting | custo |
| ---------  | ------ |------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| cassandra |  |   |   |   |   | X |   |  PRE |  Yes (libs, path, addon) |
| cf-rabbit37 |  |   |   | X  |   |   |   |  PRE | No |
| cf-redis (shared) |  |   |   |   | X |   |   |  POST | No  |
| cf-redis-osb (shared) |  |   |   |   | X  |   |   |  POST | No  |
| cloudfoundry-mysql |  |   | X  |   |   |   |   |  PRE | No |
| cloudfoundry-mysql-osb |  |   | X  |   |   |   |   |  PRE | No |
| guardian-uaa | X |   |   |   |   |   |   |  PRE | No |
| guardian-uaa-prod | X |   |   |   |   |   |   |  PRE | No |
| mongodb |   |   |   |   |   |   | X |  PRE | No |
| postgresql-docker | X  |  |   |   |   |   |   |  PRE | No |



