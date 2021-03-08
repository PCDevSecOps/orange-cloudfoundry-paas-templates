# Mongodb deployment

## Overview

The purpose of this deployment is to instantiate a mongodb cluster with its broker : 
* Mongodb broker and its smoke tests,
* Mongodb back-end (standalone server).

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | Bosh deployment |
| Depends on | [Mongodb bosh release](https://github.com/orange-cloudfoundry/mongodb-boshrelease) |
| Uses of | [Route registrar bosh release](https://github.com/cloudfoundry/route-registrar) |
| Vars files | Yes |
| Ops files | NA |

## Architecture

This deployment instantiates : 
* One mongodb server VM (standalone mode),
* One cassandra broker VM (which contains collocated errand broker smoke tests).

The broker is a Spring Boot application written in Java. It uses open source libraries : 
* Spring Boot Framework in order to ease the implementation of the Open Service Broker API,
* Maven plugin in order to run the integrations tests (provisioning and binding).

## Tips

N/A

## See also

* [Mongodb](https://www.mongodb.com/)

## To do when smoke tests fails (red in concourse)
* connect as CF Admin
* target service-sandbox org and mongodb-smoke-tests space (cf target -o service-sandbox -s mongodb-smoke-tests)
* purge service instance (cf purge-service-instance mongodb-instance)
* delete application (cf delete -r mongodb-example-app)
* trigger smoke tests with Concourse 