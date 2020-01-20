# cf-rabbit deployment

## Overview
The purpose of this deployment is to instantiate a rabbitmq cluster with its broker.
The broker is registered through scripting release (post-deploy hook).
The queue size and the vhost connections are limited (avoid noisy neighbors) 

## Summary sheet
| Item | Value |
| -- | :--: |
| Type | Bosh deployment v2|
| Depends on | [cf-rabbitmq-release](https://bosh.io/releases/github.com/pivotal-cf/cf-rabbitmq-release) |
| Depends on | [cf-rabbitmq-multitenant-broker-release](https://bosh.io/releases/github.com/pivotal-cf/cf-rabbitmq-multitenant-broker-release) |
| Depends on | [rabbitmq-smoke-tests-boshrelease](https://bosh.io/releases/github.com/cloudfoundry-community/rabbitmq-smoke-tests-boshrelease) |
| Uses of | [cf-routing-release](https://bosh.io/releases/github.com/cloudfoundry/routing-release) |
| Uses of | [cf-cli-release](https://bosh.io/releases/github.com/bosh-packages/cf-cli-release) |
| Uses of | [haproxy-boshrelease](https://bosh.io/releases/github.com/cloudfoundry-community/haproxy-boshrelease) |
| Uses of | [shield](https://bosh.io/releases/github.com/starkandwayne/shield-boshrelease) |
| Uses of | [prometheus-boshrelease](https://bosh.io/releases/github.com/cloudfoundry-community/prometheus-boshrelease) |
| Uses of | [cron-boshrelease](https://bosh.io/releases/github.com/cloudfoundry-community/cron-boshrelease) |
| Vars files | Yes |
| Ops files | Yes |

## Architecture
This deployment instantiates : 
* One broker VM
* Two backend VMs
* Two haproxy VMs 
* One VIP holds by haproxy VMs (one MASTER) => the apps are bound to this VIP

## Tips
N/A

## See also
* [cf-rabbit broker on github](https://github.com/pivotal-cf/cf-rabbitmq-multitenant-broker-release)
* [cf-rabbit on github](https://github.com/pivotal-cf/cf-rabbitmq-release)
* [cf-rabbit sample app]( https://github.com/pivotal-cf/rabbit-example-app)

## To do
N/A