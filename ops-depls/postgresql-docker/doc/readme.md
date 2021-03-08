# Postgresql-docker deployment

## Overview

The purpose of this deployment is to instantiate a mongodb cluster with its broker : 
* Postgresql back-end.

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | Bosh deployment |
| Depends on | [docker bosh release](https://github.com/cloudfoundry-incubator/docker-boshrelease) |
| Uses of | [Route registrar bosh release](https://github.com/cloudfoundry/route-registrar) |
| Vars files | Yes |
| Ops files | NA |

## Architecture

This deployment instantiates : 
* Postgresql servers VM,
* broker

The broker is a Spring Boot application written in Java. It uses open source libraries : 
* Spring Boot Framework in order to ease the implementation of the Open Service Broker API,
* Maven plugin in order to run the integrations tests (provisioning and binding).

## Tips

N/A

## To do

N/A

## Post install

### Update default max_connections
The posgres deployment is based on stolon docker.
Therefore, the following actions must be performed after the deployment :

```
#On the master keeper 
stolonctl --cluster-name=${STKEEPER_CLUSTER_NAME} --store-backend=${STKEEPER_STORE_BACKEND} --store-endpoints=${STKEEPER_STORE_ENDPOINTS} update --patch '{"automaticPgRestart":true,"pgParameters":{"max_prepared_transactions":"100","max_connections":"500"}}'

# Then restart the master keeper to activaate the configuration.
docker restart keeper
```
