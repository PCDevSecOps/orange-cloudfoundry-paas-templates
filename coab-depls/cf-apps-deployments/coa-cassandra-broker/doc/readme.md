# Coa Cassandra broker

## Overview

The purpose of this deployment is to provision cassandra bosh deployments on demand. 

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | CfApp |
| Depends on | [COAB](https://github.com/orange-cloudfoundry/cf-ops-automation-broker) |
| Vars files | NA |
| Ops files | NA |

## Architecture

The broker is a Spring Boot application written in Java. It commits in git (paas-templates/paas-secrets) bosh manifest artefacts, and scans the result in paas-secrets (output manifest file). 

## Tips

Prerequisite: the set up of the coab deployments pipeline.

## To do

N/A

## Installation steps (to be moved to RELEASE_NOTES.md)

* create COAB deployment (in paas-secrets) 
* bump paas-template release 
   * This will trigger deployment of the coab-cassandra broker 
   * COAB smoke tests will be red at 1st because some prereqs are missing:
      * coab-cassandra broker isn't yet registered within CF 
      * bosh-coa is'nt deployed yet 
* manual TF validation for bosh-coab network
* Trigger Coa-Bosh deployment 
* manual TF validation for CF registration of coab-cassandra broker and service plans   
* relaunch COAB deployment to retrigger smoke tests: smoke tests should be green.

## Day 2 operation steps 
* periodically manually review deleted deployment and accept them by launching the associated concourse job  
* limitations: no backup, monitoring

### create COAB deployment (in paas-secrets)

A dedicated root deployment is a prerequisite to hold the on-demand bosh deployments. This root deployment includes:
* a bosh director along with a dedicated network subnet
* a prometheus instance