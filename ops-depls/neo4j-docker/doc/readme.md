# neo4j-docker deployment

## Overview

The purpose of this deployment is to instantiate a neo4j backend with its broker.
The broker is registered through terraform (ops-depls/cloudfoundry/terraform-config/service-brokers.tf).

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | Bosh deployment v2|
| Depends on | [docker-boshrelease](https://bosh.io/releases/github.com/cf-platform-eng/docker-boshrelease) |
| Uses of | [routing-release](https://bosh.io/releases/github.com/cloudfoundry/routing-release) |
| Vars files | Yes |
| Ops files | No |

## Architecture

This deployment instantiates only one VM which holds the backend and the broker.

## Tips

N/A

## See also

* [docker-boshrelease](https://github.com/cloudfoundry-incubator/docker-boshrelease/)
* [cf-neo4j-example-app](https://github.com/cloudfoundry-attic/cf-neo4j-example-app)


## To do

N/A