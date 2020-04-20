# memcache deployment

## Overview

The purpose of this deployment is to instantiate a memcache server with its broker.
The broker is registered through terraform (ops-depls/cloudfoundry/terraform-config/service-brokers.tf).

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | Bosh deployment v2|
| Depends on | [memcache bosh release](https://bosh.io/releases/github.com/cloudfoundry-community/memcache-release) |
| Uses of | [routing bosh release](https://bosh.io/releases/github.com/cloudfoundry/routing-release) |
| Vars files | Yes |
| Ops files | NA |

## Architecture

This deployment instantiates : 
* One memcache broker VM (which contains the route_registrar job and the broker job)
* Two memcache VMs (each node contains the memcache_hazelcast job)

## Migration strategy (from bosh1 to bosh2 deployment)

There are no bindings in production which refer to the bosh1 IPs. 
The migration appoach is to give an information to the projects (cf unbind, cf bind and cf restage)

## Tips

N/A

## See also

* [memcache on github](https://github.com/cloudfoundry-community/memcache-release)
* [memcache on bosh io](https://bosh.io/releases/github.com/cloudfoundry-community/memcache-release)


## To do

N/A