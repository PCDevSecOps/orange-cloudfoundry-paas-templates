# Overview
## Principles
### Gitops
We expect platform operators to interact with the platform mostly with git commands. Each platform instance holds its own git server, template git repo and template secrets.

### recommanded skills / reading

- cloudfoundry definitive guide: 
- Ultimate Guide to Bosh:  https://ultimateguidetobosh.com/

### cf ops automation - COA
Our automation is based on git, and concourse.
see: 
- https://concourse-ci.org/
- https://github.com/orange-cloudfoundry/cf-ops-automation

### paas-templates
### Features branches - hotfixes
### no spof architecture and hot update
### network policy
patterns:
- virtual networking: the solution requires a private virtual network capability. The virtual subnet use heavily 192.168.x.x.
- private dns: we embed a private dns for fine grained control of dns resolution, with no dependency on iaas / runner ecosystem beyond dns recursors.
- interco: the private virtual subnet need some interco vm to be accessed, with intranet provided ip, or public internet adress (floating ip). Multi NIC network attachement, or static tcp routing are the 2 possible interco mechanism

## Constraints
### boostraping
### per iaas-type configuration

### multi-az
We use bosh logical multi-az. Some iaas do not support genuine az. In that case, we map the bosh logical azs to one technical az.
NB: do not confuse multi az iaas, and multiple regions. Bosh has good support for multi-az, but a single director can not manage multiple iaas apis / regions.

## Configuration and Secrets Management
### Credhub

Credhub is the Cloudfoundry community solution to hold secrets. It provides good integration with bosh, concourse, and terraform.

### Shared secrets

### deployment level secrets
This secrets are managed in secrets repo, in sibbling tree location. As we generalize credhub, we should have no more secrets in theses location

Note: we keep sizing elements, like number of cell, number of gorouters in local files, secrets/meta.yml
Note 2: as of COA 3.5, to solve scalability issues, there is no local deployment scanning default. Author must explicitly require local secrets scannning

## DNS policy
### intranet / internet recursors

We expect to be provided recursors:
- 1 internet recursor.
- 1 intranet recursor per managed intranet interco

As of v34, the private dns recurses to the internet.

### private dns domain

We provide a deployment with a ha pair of powerdns/dnqmasq servers. The dnsmasq container fronts each powerdns to ensure correct resolution/recursion. It is populated and maintained by terraform spec files, and persists its date in an active/passive mysql cluster.

The powerdns holds the following zone:
- internal.paas
- split brain dns for api domain
- split brain dns for intranet domain
- split brain dns for internet domain ==> TO REMOVE
- any9 dedicated zone for ondemand commercial OSB services ==> TO REMOVE
- recursion to internet dns servers 

The private powerdns ip pair is configured on all iaas tenant bosh network, as dns servers.

NB: we dont use bosh director provided powerdns job, as its a known spof, and not recommanded by the community. see bosh-dns below

NB: cloudfoundry isolation segment features enables us to dedicate iaas network per intranet, and associate per intranet dns recursor and routes on the networks


### bosh-dns

This is a new feature for Bosh. The bosh directors has the state of each of the vm it deploys. He is able to affect dns name to each vm, and transmit on the fly the available dns / alias to childs vms.

see: 

We take advantage of this feature for intra director wiring

NB: the bosh-dns scope is by default limited to a single directors. It can not be used to resolve vms from another director 

## Identity and security
### embedded ldap

We provide en embedded openldap server. It holds end-user and plateform operators identity (user name / mail / password).
A ldap group is provided for platform operators, assigning them the required uaa-scopes (mapped in the description field of the ldap group)
A self service password management is provided (PWM - Password Manager)

### UAA facade, and scope management

## Monitoring and Metrics
### ELK logsearch
### ops metrics collection
### cloudfoundry apps metrics collection
We leverage the Cloudfoundry firehose collection

### Access control
The configuration is based on cloudfoundry UAA, based on org (for logsearch-ops, system_doman), or space (for logsearch-aps). Logsearch uses UAA Oauth to authenticate, and access the cloudfoundry API to retrieve then control the org/space, and filter the logs accordingly.

## Metrics and alert management
### prometheus and grafana

Metrics are collected, persisted and accessed thanks to prometheus bosh release.

patterns:
- metrics retention: we configured a 2 weeks metrics retention, to keep acceptable performance
- io performance: prometheus has a high io consumption, with 1 file per metric. To avoid reaching inode limits, we use xfs filesystem formating (instead of bosh default ext4).

see: 
- https://github.com/bosh-prometheus/prometheus-boshrelease

### prometheus federation

stateless prometheus
federation scraping

### alertmanager

escalation policy:
- mail
- runner specific interco

## Backups
### shield

see: 
- https://github.com/starkandwayne/shield-boshrelease

### s3 storage
A remote s3 storage is required to hold the backup. We use a single s3 account per platform, and one bucket per backup job. Shield takes care of saving the backup, in daily directory. It also purges the old backup according to the configured retention.

For better availability, and "out of iaas" s3 is recommended. We provide orange OBOS default config.

### shield v7 autoregistration
With shield v7, we configure shield-agent on all vm with a bosh persistent disk.
The agent runs the backup locally, with appropriate agent (postgres/fs/xtrabackup)
As it runs locally, it has no wiring issue (localhost), nor authentication issue. Shield agent is able to register the backup configuration remotely to the shield server (source, target, recurrence, retention policy).

NB: this mechanism enables auto backup configuration. A central (from shield server manifest) configuration would be less maintenable (central config point). Distributing the backup configuration has the draw back of inducing some cyclic dependency in the bootstrap phase. Shield v8 should solve this limitation, as configuration will be done with bosh errands (ie: wont block bosh deployment phase).

## Smtp
technical intranet relay on interco depl.

## Routing and access zones
### http_proxy to intranet

### http_proxy to internet

## Ops Domain portals

## Cloudfoundry configuration
### automated terraform configuration

patterns:
- terraform cloudfoundry
- terraform credhub
- terraform openstack

### system_domain org

this org is dedicated to platform operation cf apps (eg: OSB api broker, stratos ui portal)

### intranet org
### internet org - internet isolation segment
### application security groups - ASG


## OSB Marketplace
### bosh release shared services

### docker bosh release services

To provide an HA solution, the postgres service is not based on postgres bosh release, but on docker bosh release, with carefully crafted configuration to deploy a container based multi VM HA architecture

### broker registration

We use terraform cloudfoundry plugin to register the osb broker in cloudfoundry

### service org visibility

### spring cloud config server

### static credential broker

### sec group broker filter
this broker is an OSB API facade broker, wich intercepts OSB bind / unbind order to create/set space level applications security groups.
see: 

### COAB - cf ops automation broker
this generic broker is in charge of implementing en OSB API broker, to populate bosh-deployment or k8s kubernetes on create/delete verbs.
see: 

### Limits
shared marketplace
billing
network exposition issue

## Tooling
### ops-portal
### stratos-ui
### password manager PWM
### weave-scope
### metabase BI


## Kubo Container Runtime
### openstack config
#### human_readable_vm
#### k8s cloud_config properties
#### cinder
#### lbaas v2
