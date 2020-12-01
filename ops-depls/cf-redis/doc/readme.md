# cf-redis deployment

## Overview

The purpose of this deployment is to instantiate a redis cluster with its broker.

The security group broker filter (deployed in ops-depls/cf-apps-deployments/sec-group-broker-filter-cf) is put in front of the cf-redis broker.

The broker is registered through terraform (ops-depls/cloudfoundry/terraform-config/service-brokers.tf).

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | Bosh deployment v2|
| Depends on | [cf-redis bosh release](https://bosh.io/releases/github.com/pivotal-cf/cf-redis-release) |
| Uses of | [routing bosh release](https://bosh.io/releases/github.com/cloudfoundry/routing-release) |
| Vars files | Yes |
| Ops files | Yes (migration) |

## Architecture

This deployment instantiates : 
* One cf-redis broker VM (which contains the route_registrar job, the broker job and collocated smoke tests)
* Five cf-redis nodes VMs (each node contains the dedicated-node job)

## Migration strategy (from bosh1 to bosh2 deployment)

There are about 100 bindings in production which refer to the bosh1 IPs (broker for shared plan and nodes VMs for dedicated plan). 

The migration appoach is to keep the bosh1 IP in the deployment for the broker and the back-end.

Two networks are available : tf-net-services for bosh1 deployments and tf-net-services-2 for bosh2 deployments.

The new bosh2 deployment (all VMs) refer to the tf-net-services-2 in the manifest. 

This is achieved by a custom bosh operator (patch-legacy-bosh1-service-bindings-operators.yml) for openstack iaas-type which override IPs.

## Tips

N/A

## See also

* [cf-redis on github](https://github.com/pivotal-cf/cf-redis-release)
* [cf-redis on bosh io](https://bosh.io/releases/github.com/pivotal-cf/cf-redis-release)
* [cf-redis sample app](https://github.com/pivotal-cf/cf-redis-example-app)


## To do when smoke tests fails (red in concourse)
* connect as CF Admin
* remove redis-smoke-test-org (cf delete-org redis-smoke-test-org)
* trigger smoke tests with Concourse

## Ops functions - backup/restore (shield)
* fully automated

## Ops functions - monitoring (prometheus/grafana)
* dedicated nodes => automated thanks to scripting release (pre-start hook) but need a restart (bosh -d cf-redis restart)
* shared node => not automated yet (crontab bosh release to test)




 