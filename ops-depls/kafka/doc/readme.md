# kafka deployment

## Overview

The purpose of this deployment is to instantiate a kafka backend with its broker.
The broker is registered through terraform (ops-depls/cloudfoundry/terraform-config/service-brokers.tf).

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | Bosh deployment v2|
| Depends on | [kafka-boshrelease](https://bosh.io/releases/github.com/cloudfoundry-community/kafka-boshrelease) |
| Depends on | [kafka-service-broker-boshrelease](https://bosh.io/releases/github.com/cloudfoundry-community/kafka-service-broker-boshrelease) |
| Uses of | [routing-release](https://bosh.io/releases/github.com/cloudfoundry/routing-release) |
| Uses of | [bpm-release](https://bosh.io/releases/github.com/cloudfoundry/bpm-release) |
| Uses of | [zookeeper-release](https://bosh.io/releases/github.com/cppforlife/zookeeper-release) |
| Vars files | Yes |
| Ops files | Yes |

## Architecture

This deployment instantiates : 
* One broker VM
* Four kafka backend VMs
* Three zookeeper backend VMs

## Tips

N/A

## See also

* [kafka on github](https://github.com/cloudfoundry-community/kafka-boshrelease)
* [kafka broker on github](https://github.com/cloudfoundry-community/kafka-service-broker-boshrelease)
* [kafka-example-app]( https://github.com/pivotal-cf-experimental/kafka-example-app)


## To do

N/A