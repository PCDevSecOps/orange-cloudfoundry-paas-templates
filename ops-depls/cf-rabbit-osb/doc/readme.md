# cf-rabbit deployment

## Overview

The purpose of this deployment is to instantiate a rabbit backend with its broker.
The broker is registered through terraform (ops-depls/cloudfoundry/terraform-config/service-brokers.tf).

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | Bosh deployment v2|
| Depends on | [cf-rabbitmq-multitenant-broker-release](https://bosh.io/releases/github.com/pivotal-cf/cf-rabbitmq-multitenant-broker-release) |
| Depends on | [cf-rabbitmq-release](https://bosh.io/releases/github.com/pivotal-cf/cf-rabbitmq-release) |
| Uses of | [cf-routing-release](https://bosh.io/releases/github.com/cloudfoundry-incubator/cf-routing-release) |
| Uses of | [cf-cli-release](https://bosh.io/releases/github.com/bosh-packages/cf-cli-release) |
| Vars files | Yes |
| Ops files | Yes (migration)|

## Architecture

This deployment instantiates : 
* One broker VM
* One backend VM
* One haproxy VM (the apps are bound to the IP hold by this VM)

## Migration strategy (from bosh1 to bosh2 deployment)

There are about 200 bindings in production which refers to the bosh1 IP (haproxy). 

The migration appoach is to keep the bosh1 IP in the deployment for the haproxy.

Two networks are available : tf-net-services for bosh1 deployments and tf-net-services-2 for bosh2 deployments.

The new bosh2 deployment (all VMs) refer to the tf-net-services-2 in the manifest. 

The migration is achieved by a custom bosh operator (patch-legacy-bosh1-service-bindings-operators.yml) for openstack iaas-type which override IP.

## Tips

N/A

## See also

* [cf-rabbit broker on github](https://github.com/pivotal-cf/cf-rabbitmq-multitenant-broker-release)
* [cf-rabbit on github](https://github.com/pivotal-cf/cf-rabbitmq-release)
* [cf-rabbit sample app]( https://github.com/pivotal-cf/rabbit-example-app)


## To do

N/A