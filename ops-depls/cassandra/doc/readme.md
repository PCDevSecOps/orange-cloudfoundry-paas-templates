# Cassandra deployment

## Overview

The purpose of this deployment is to instantiate a cassandra cluster with its broker : 
* Cassandra broker and its smoke tests,
* Cassandra back-ends (servers and seeds).

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | Bosh deployment |
| Depends on | [Cassandra bosh release](https://github.com/orange-cloudfoundry/cassandra-cf-service-boshrelease) |
| Uses of | [Route registrar bosh release](https://github.com/cloudfoundry/route-registrar) |
| Vars files | Yes |
| Ops files | NA |

## Architecture

This deployment instantiates : 
* Three cassandra seeds VMs,
* One cassandra server VM,
* One cassandra broker VM (which contains collocated errand broker smoke tests).

The broker is a Spring Boot application written in Java. It uses open source libraries : 
* Spring Boot Framework in order to ease the implementation of the Open Service Broker API,
* Cassandra Unit library in order to run the integrations tests (provisioning and binding).

## Tips

N/A

## See also

* [Apache Cassandra](http://cassandra.apache.org/)

## To do when smoke tests fails (red in concourse)
* connect as CF Admin
* target service-sandbox org and cassandra-smoke-tests space (cf target -o service-sandbox -s cassandra-smoke-tests)
* purge service instance (cf purge-service-instance cassandra-instance)
* delete application (cf delete -r cassandra-example-app)
* trigger smoke tests with Concourse 



