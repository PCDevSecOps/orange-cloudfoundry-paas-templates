# Conventions

* When you encounter `<var>` syntax in this document, you have to replace it with content of `var` item.  
**E.g.:** Replace `<ip>` with **instance ip**

* `$` in code section is the prompt session, followed by command

``` bash
$ log-bosh
```

# Bosh

## Design

### Add a new deployment
* Create a `<deployment>` name directory, under the chosen bosh director deployment (e.g. `master-depls/cf-rps`)
* Create `template` directory
* Add bosh manifest `<deployment>-tpl.yml` or `<deployment>.yml`. See cf-ops-automation [COA naming conventions](https://github.com/orange-cloudfoundry/cf-ops-automation#resource-lifecycle-overview)
* Add bosh operators files `xx-operators.yml` if needed (be care of naming operators, for ordering operations in the right way)
* Add bosh vars files `xx-vars-tpl.yml` or `xx-vars.yml` if needed (be care of naming operators, for ordering operations in the right way)
* Add iaas specific bosh operators (e.g. `openstack-hws/yyy-operators.yml`) wich are applied only for specific `iaas-type`

### Add runtime-config
Bosh `runtime-config` enhanced all bosh deployments within a director.  
Typically used to add agent (syslog, shield agent) to each instance of all bosh deployments.

Runtime operators are yml files which follow [COA naming conventions](https://github.com/orange-cloudfoundry/cf-ops-automation#resource-lifecycle-overview)
* Specify a `runtime-config.yml` file
* Add runtime operator `<root-deployment>/template/xxx-runtime-operators`
* Add iaas specific runtime operator `<root-deployment>/template/<iaas-type>/xxx-runtime-operators`

**Advanced usage:** You can use `runtime-config` to modify specific deployments, with `include` and /or `exclude` clause.

**Example:** ops-depls/template/ (ops-depls stands for )

### Define bosh networks, map to iaas
Bosh `cloud-config` allow to map bosh level constructs (networks, vm_type, disk_type) to iaas level concepts / id.
* Add base cloud-config `<root-deployment>/template/cloud-config.yml`
* Add cloud-config operators `<root-deployment>/template/xxxx-cloud-operators.yml`
* Add iaas specific cloud-config operators `<root-deployment>/template/<iaas-type>/xxxx-cloud-operators.yml`

## Troubleshoooting

### Check iaas consistency with bosh inventory

``` bash
$ bosh cloud_check
```

> **Notes:**  
> This command checks iaas artifacts (disks, vms) with bosh expected iaas artifacts inventory.  
> It does not check that monit services are up.

### Recover data after bosh delete-deployment
When deleting a deployment, bosh inventory and vms are delete, but persistent disks have, however, a grace period.  
Operators can list them with followin command:

``` bash
$ bosh disks --orphaned
```

If needed, operators can deploy a fresh deployment, then force orphaned disk attachement to replace the new disks with previous data.

> **Caution:**
> * Be sure to match the correct instance group index when reattaching.
> * The freshly created disks will become orphaned. You have to delete them afterwards

### Troubleshooot a job
If you need to troubleshoot jobs inside a bosh instance, you can follow process (choose director `depls` where the target deployment runs):

``` bash
$ log-bosh
$ bosh instances
$ bosh ssh <instance id>
$ sudo -i
$ monit summary
```

Then when you kow which job is concerned by trouble, look at specific logs in:

``` bash
$ cd /var/vcap/sys/log/<job name>
```

### ssh to bosh-micro

on bosh-cli, assuming a clone of secrets repo exists in ~/bosh/secrets/shared/keypair/bosh.pem

Identify the IP address of the micro-bosh (usually `192.168.10.10`)
```
log-bosh
bosh env
```

```
chmod 600 ~/bosh/secrets/shared/keypair/bosh.pem
ssh -i ~/bosh/secrets/shared/keypair/bosh.pem vcap@192.168.10.10 
```

### log to bosh-micro with admin account using cli

When LDAP deployment is down (symptom `Failed to authenticate with UAA`), 
try to connect to bosh-micro using `admin` account, to use interact with bosh director from the cli.

* Step 1: get bosh-micro admin password from credhub
   * `log-credhub` or its fallback:
   * lookup in `shared/secrets.yml` `bosh.admin.password`
   * `credhub login --client-name=director_to_credhub  --client-secret=bosh_admin_password
* Step 2:
```bash
export BOSH_ENVIRONMENT=192.168.10.10
bosh login
#email=admin
#password=password previously obtained through shared/secrets
```

```
# Concourse / COA

## Design

### Documentation on concourse-ui
* [General tutorial on concourse-ui](https://medium.com/concourse-ci/concourse-pipeline-ui-explained-87dfeea83553)
* [cf-ops-automation (COA)](https://github.com/orange-cloudfoundry/cf-ops-automation#cf-ops-automation-coa)

### Deploy a new version of paas-templates
**COA** manages everything from git. Basically, an update is a git push to the platform git repository.  
**COA** then takes care of applying required changes to each element of the platform.  
Risk is reduced, as the tools used are essentially declarative and idempotent.

### Custom concourse pipelines
All pipelines in concourse are managed by **COA** (managed means generation, save into GIT and apply).  
However, you can add your own custom concourse pipelines. bosh 2 syntax (and spruce templating) is available for modular pipeline editing.

* Add a concourse file definition `<root-deployment>/<deployment>/concourse-pipeline-config/xxxx.yml`
* Add operators to customize concourse manifest `<root-deployment>/<deployment>/concourse-pipeline-config/yyy-operators.yml`

**Example:** `master-depls/cached-buildpack-pipeline/concourse-pipeline-config`

## Troubleshoooting

### Resolve `max-containers reached` issue
Under heavy load, concourse workers can exceed garden limitations (250 containers per vm worker).  
This can be confirmed with grafana dashboards (e.g on https://elpaaso-prometheus-grafana.<redacted_ops_domain>/d/concourse_overview/concourse-overview?refresh=30s&orgId=1)  
In this case, you have to:

* Recreate concourse workers:

``` bash
bosh -d concourse recreate worker
bosh -d concourse recreate worker-2
```

* Then with concourse web-ui, go on each deployment with orange pipeline block (they reached max containers), use `utils` menu and click on `retrigger all jobs`

### Upload old concourse resources versions
Several jobs in **COA** allow to get stemcells/bosh-releases/buildpacks resources, but sometimes versions defined in paas-templates are older then latest one.  
You can load old releases with following process:

1. For bosh **`stemcells`** and **`releases`** offline management

* Check resources in trouble in `upload` team:

``` bash
$ log-fly
$ fly -n upload
$ fly -t concourse check-resource -r kubo-depls-s3-br-upload-generated/bosh-dns-boshrelease -f version:1.5.0
```

* With concourse web-ui, log to `ulpoad` team
* Trigger jobs (e.g. `upload-current-credhub`) in pipelines (e.g. `micro-depls-s3-br-upload-generated`) to upload resources in trouble

2. For **`cached buildpacks`**

* Check resources in trouble in `main` team:

``` bash
$ log-fly
$ fly -t concourse check-resource -r master-depls-cached-buildpack-pipeline/php-bp-release -f ref:v4.3.63
$ fly -t concourse check-resource -r master-depls-cached-buildpack-pipeline/binary-bp-release -f ref:v1.0.23
$ fly -t concourse check-resource -r master-depls-cached-buildpack-pipeline/python-bp-release -f ref:v1.6.20
$ fly -t concourse check-resource -r master-depls-cached-buildpack-pipeline/go-bp-release -f ref:v1.8.26
$ fly -t concourse check-resource -r master-depls-cached-buildpack-pipeline/ruby-bp-release -f ref:v1.7.22
$ fly -t concourse check-resource -r master-depls-cached-buildpack-pipeline/nodejs-bp-release -f ref:v1.6.30
$ fly -t concourse check-resource -r master-depls-cached-buildpack-pipeline/staticfile-bp-release -f ref:v1.4.28

$ fly -t concourse check-resource -r master-depls-cached-buildpack-pipeline/java-bp-release -f tag:v4.15
```

* With concourse web-ui, select resource (e.g. `php-bp-release`) in `master-depls-cached-buildpack-pipeline`
* Unselect versions up to desired version (allow **COA** to upload specific resource instead of latest one)
* Trigger jobs (e.g. `deploy-php`) to upload resources in trouble
* When jobs turn green, reselect all versions in associated resources

### Hijack a concourse container (debug a pre-deploy or a post-deploy task for instance)

* Identify a failure concourse build via Concourse GUI (https://elpaaso-concourse.<OPS_DOMAIN>/teams/main/pipelines/coab-depls-bosh-generated/jobs/deploy-mongodb/builds/227)

* Connect to build and choose the container to hijack

``` bash
$ log-fly
$ fly i -u https://elpaaso-concourse.<OPS_DOMAIN>/teams/main/pipelines/coab-depls-bosh-generated/jobs/deploy-mongodb/builds/227
```

### Resolve resource check error

Symptom: the concourse resource check fails and is display in orange color in concourse ui 

```
resource script '/opt/resource/check []' failed: exit status 128

stderr: [...]
```

Resolution:
* identify and fix root cause
* recreate concourse workers to kill all containers performing resource check 

``` bash
bosh -d concourse recreate worker
bosh -d concourse recreate worker-2
```

* trigger explicitly resource check (e.g. for resource `cf-ops-automation` in pipeline `bootstrap-all-init-pipelines`)

``` bash
fly cr -r bootstrap-all-init-pipelines/cf-ops-automation
```

### Update cloud-config on concourse micro

Symptom: concourse fails to deploy because of an unapplied change in cloud-config.

* Edit cloud-config copy from secret repo in `./micro-depls/cloud-config.yml` and commit.
* in bosh-cli, pull the repo
```bash
bosh update-cloud-config ./micro-depls/cloud-config.yml
```
* trigger a bosh deployment
   * if concourse manifest is outdated in git secrets repo

```bash
bosh manifest -d concourse > current_concourse.yml
bosh deploy -d concourse  ./current_concourse.yml 
```

Potentially clean up stalled workers

```bash
for W in $(fly workers | grep "stalled" | awk '{print $1}') ; do fly prune-worker -w $W ; done   
```

Then manually trigger `micro-depls-bosh-generated/cloud-config-and-runtime-config-for-micro-depls` concourse job 
(to make sure secrets repo gets updated and properl reflect deployed state)   


# Docker

## Troubleshooting

### Troubleshoot a container
* Connect to the instance (see [Troubleshoot a job](#Troubleshooot-a-job))
* Connect in a specific container

``` bash
$ docker ps -a
$ docker exec -it <container id> sh
```

**Usefull commands (instance level only):**

``` bash
$ docker system df
TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
Images              5                   4                   610MB               5.116MB (0%)
Containers          4                   4                   2.07kB              0B (0%)
Local Volumes       1                   1                   0B                  0B
Build Cache                                                 0B                  0B

$ docker ps -a
$ docker images
```

# System

## Troubleshoooting

### Iptables

* Show `iptables` access

``` bash
$ iptables -L -t nat | grep DNAT
```

### Network

* Show open ports on instance

``` bash
$ netstat -lntp
```

* Check port on instance

``` bash
$ nc -vz <instance ip> <port>
```

* Check port on instance

``` Show tcp route on domain
$ mtr test.<doamin> -P <port>
```

* Dump tcp traffic

``` bash
$ tcpdump -n -A src <ip>
```

### Certs

* Read cert from cert file

``` bash
$ openssl x509 -text -noout -in <file>.crt
```

* Check a certificate from a remote http server

``` bash
$ echo "" | openssl s_client -CAfile <path to ca cert file> -connect <domain>:443
```

* List certs from a remote http server

``` bash
nmap --script ssl-cert,ssl-enum-ciphers -p 443 <domain>
```

# Terraform

## Design

### Terraform setting
Bosh is able to manage a great deal of architecture configuration, with an idempotent approach.  
Terraform has the same idempotent / declarative approach.  
You shoud use terraform to manage non bosh managed configurations:
* Iaas-level subnets, routers, openstack ports, security groups
* Cloudfoundry level security groups, org, space, brokers
* Private powerdns records
* Public saas (e.g. cloudflare)

**Definition:**
* Add terraform spec files in <root-deployment>/terraform-config/xxx.spec
* Add iaas-specific terraform spec files in <root-deployment>/terraform-config-<iaas-type>/yyy.spec

### Terraform and credhub
* Terraform spec can retrieve iaas credentials from credhub (url / user / password ...) 

**Exemple with `powerdns-docker` deployment:**

``` yaml
data "credhub_value" "powerdns_api_key" {
  name = "/secrets/powerdns_api_key"}

data "credhub_value" "powerdns_server_ip" {
  name = "/secrets/powerdns_server_ip"}

provider "powerdns" {
    api_key = "${data.credhub_value.powerdns_api_key.value}"
    server_url = "${format("http://%s:8088",data.credhub_value.powerdns_server_ip.value)}"
}
```

* Terraform spec can save the resulting net-id in credhub when create a iaas subnet.  
This id can be use later by bosh directors when deploying.

**Exemple with `intranet-2` network:**

``` yaml
resource "credhub_generic" "openstack_networks_net-intranet-2" {
  type       = "value"
  name       = "/tf/openstack_networks_net-intranet-2"
  data_value = "${openstack_networking_network_v2.tf-net-intranet-2.id}"
}
```

## Troubleshoooting

### Fix inconsistent `terraform.state` file
TBC

# UAA

## Design

### Use uaac cli to manage users / oauth client
See [Managing Users with the UAA CLI](https://docs.cloudfoundry.org/uaa/uaa-user-management.html)

## Troubleshoooting

### List clients

``` bash
$ log-uaa
$ uaa list-clients
```

# Web routing

## Design

### How to expose a web app
Use `routing-release/route_registrar job`. This job can expose a private ip/port on a gorouter (cloudfoundry gorouter or ops dedicated gorouter).  
By default, the backend must be exposed in http. Usually you have to configure the public exposed route in the backend software.

**Examples:**
* `kubo-depls/cfcr`, haproxy instance group
* `micro-depls/concourse`
* `master-depls/prometheus`, grafana instance-group
