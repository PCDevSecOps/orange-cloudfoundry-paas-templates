Osb-Cmdb provides a single OSB exposition endpoint for all brokers

<!-- TOC initiated with [gh-md-toc](https://github.com/ekalinin/github-markdown-toc) -->
<!--ts-->
   * [Overview](#overview)
      * [Osb-cmdb instance + backing CF org per OSB service consumer](#osb-cmdb-instance--backing-cf-org-per-osb-service-consumer)
      * [Osb-reverse-proxy per 3rd party service provider](#osb-reverse-proxy-per-3rd-party-service-provider)
   * [Common use-cases](#common-use-cases)
      * [Adding a new osb service consumer](#adding-a-new-osb-service-consumer)
         * [Enable a new osb-cmdb instance](#enable-a-new-osb-cmdb-instance)
         * [Configure osb-cmdb instance](#configure-osb-cmdb-instance)
         * [Make backing service(s) plan(s) visible to service consummer](#make-backing-services-plans-visible-to-service-consummer)
      * [Adding a new 3rd party service broker](#adding-a-new-3rd-party-service-broker)
         * [Enable and configure a new osb-reverse-proxy instance](#enable-and-configure-a-new-osb-reverse-proxy-instance)
         * [Register the proxied service-broker in master-depls/cf](#register-the-proxied-service-broker-in-master-deplscf)
         * [Make 3rd party service offering available to service consumer(s)](#make-3rd-party-service-offering-available-to-service-consumers)
         * [Set up osb-cmdb OSB smoke test](#set-up-osb-cmdb-osb-smoke-test)
         * [Validate usage of 3rd party service from osb service consummers](#validate-usage-of-3rd-party-service-from-osb-service-consummers)
      * [Adding a new paas-templates service broker](#adding-a-new-paas-templates-service-broker)
      * [Configuring quota per osb service consumer](#configuring-quota-per-osb-service-consumer)
         * [Assigning quota to a given osb client](#assigning-quota-to-a-given-osb-client)
         * [Tracking quota usage](#tracking-quota-usage)
   * [Contributing to osb-cmdb in paas-templates](#contributing-to-osb-cmdb-in-paas-templates)
      * [Updating symlinked instances](#updating-symlinked-instances)
<!--te-->

## Overview

See https://github.com/orange-cloudfoundry/paas-templates/issues/492 for background.

This README.md only covers the specifics of using osb-cmdb through paas-templates. The osb-cmdb generic features and operations are instead detailed in [https://github.com/orange-cloudfoundry/osb-cmdb](https://github.com/orange-cloudfoundry/osb-cmdb)

Each Osb-cmdb instance is a broker which requests CF service instances and service keys in master-depls/cf in backend CF org.

### Osb-cmdb instance + backing CF org per OSB service consumer

There is one instance of Cmdb per Osb client (osb-cmdb-broker-0, ... osb-cmdb-broker-4).
* Per convention, osb-cmdb-broker-0 is dedicated to master-depls-cf osb client
* Per convention, the canoncial template instance (osb-cmdb-broker) is not enabled

Each service consumer has its associated backing CF org, with a space for each backing service offering.

See [https://github.com/orange-cloudfoundry/osb-cmdb#typical-cmdb-content](https://github.com/orange-cloudfoundry/osb-cmdb#typical-cmdb-content) for an example

### Osb-reverse-proxy per 3rd party service provider

Each 3rd party service broker needs to be proxied to be reacheable by master-depls/cf: cf has no configured http_proxy to reach intranet or internet urls. Also Cf does not collect logs of OSB calls made to service brokers.

## Common use-cases

### Adding a new osb service consumer

#### Enable a new osb-cmdb instance

* Pick the next available index (say N) in the paas-templates/ops-depls/cf-apps-deployments/osb-cmdb-broker-* list
* Enable the cf app by creating through `secrets/ops-depls/cf-apps-deployments/osb-cmdb-broker-N/enable-cf-app.yml`

#### Configure osb-cmdb instance

in secrets/ops-depls/cf-apps-deployments/osb-cmdb-broker-N/secrets/secrets.yml

```yaml
  osb-cmdb-broker:
    name: user # broker basic auth user name
    # Default org and space are used to dynamically generate catalog, and provision backend services.
    # Warning: overlapping service names among registered service brokers are not supported in default org.
    default-org: cmdb-cf-z1-services # Should be available when osb-cmdb starts. Paas-templates will create it automatically if create-default-org is set to true
    default-space: default # Should be available when osb-cmdb starts. Paas-templates will create it automatically if create-default-org is set to true
    create-default-org: true # Whether default org and default space should be created when missing
```

in secrets/ops-depls/cf-apps-deployments/osb-cmdb-broker-N/secrets/meta.yml configure the dynamically osb service catalog, which is fetched from backing service offerings catalogs

```yaml
meta:
  osb-cmdb-broker:
    # overrides application.yml in the osb-cmdb.jar files
    application_yml:
#### Dynamic catalog configuration
      osbcmdb:
        dynamic-catalog:
          enabled: "true" #Turn on dynamic catalog. Catalog and brokered services should be commented out.
          catalog:
            services:
              suffix: ""
              excludeBrokerNamesRegexp: ".*cmdb.*"
#### Manual catalog and brokered service configuration 
# Catalog should likely be adapted from dynamic catalog generation that is dumped by the broker on disk onto /tmp/osb-cmdb-dynamicCatalog.yml
# This would ensure that new defaults in osb version get properly assigned during bump.
# Dynamic catalog  can be retrieved locally by a command such as:
#     cf ssh osb-cmdb-broker-0 -c 'cat /tmp/osb-cmdb-dynamicCatalog.yml' > mycatalog.yml
# 
#      spring:
#        cloud:
#          openservicebroker:
#            catalog:
#              services:
#                - name: p-mysql-cmdb
#                  id: ebca66fd-461d-415b-bba3-5e379d671c88
#                  description: A useful service
#                  bindable: true
#                  plan_updateable: true
#                  tags:
#                    - example
#                  plans:
#                    - name: 10mb
#                      id: p-mysql-cmdb-10mb
#                      description: A standard plan
#                      free: true
#                    - name: 20mb
#                      id: p-mysql-cmdb-20mb
#                      description: A standard plan
#                      free: true
#                - name: noop-ondemand-cmdb
#                  id: noop-ondemand-cmdb-guid
#                  description: A useful service
#                  bindable: true
#                  plan_updateable: false
#                  tags:
#                    - example
#                  plans:
#                    - name: default
#                      id: noop-ondemand-cmdb-default-plan-guid
#                      description: A standard plan
#                      free: true
#
#
#          appbroker:
#            services:
#              - service-name: p-mysql-cmdb
#                plan-name: 10mb
#                target:
#                  name: SpacePerServiceDefinition
#                services:
#                  - service-instance-name: p-mysql
#                    name: p-mysql
#                    plan: 10mb
#              - service-name: p-mysql-cmdb
#                plan-name: 20mb
#                target:
#                  name: SpacePerServiceDefinition
#                services:
#                  - service-instance-name: p-mysql
#                    name: p-mysql
#                    plan: 20mb
#              - service-name: noop-ondemand-cmdb
#                plan-name: default
#                target:
#                  name: SpacePerServiceDefinition
#                services:
#                  - service-instance-name: noop-ondemand
#                    name: noop-ondemand
#                    plan: default
```

#### Make backing service(s) plan(s) visible to service consummer

For each backing service (either paas-templates or 3rd party service), decide whether to expose the service plans to the service consummer. This is done by making the backing service plan visible in the corresponding osb-cmdb service consummer backing org.

You may choose to use common-broker-scripts on the osb-reverse-proxy or paas-templates service broker to manage the service plan visibility

See [common-broker-scripts/README.md#service-plan-visibility](../../../coab-depls/common-broker-scripts/README.md#service-plan-visibility)

Then restart the osb-cmdb instance.

### Adding a new 3rd party service broker

#### Enable and configure a new osb-reverse-proxy instance

Refer to [osb-reverse-proxy/README.md](../osb-reverse-proxy/README.md) for further details
This requires enabling an osb-reverse proxy instance.

#### Register the proxied service-broker in master-depls/cf

You may choose to use common-broker-scripts on the osb-reverse-proxy to register the service broker in master-depls/cf

See [common-broker-scripts/README.md#broker-registration](../../../coab-depls/common-broker-scripts/README.md#broker-registration)

#### Make 3rd party service offering available to service consumer(s)

For master-depls/cf to provision the backing service instance for a service consumer, the service plan needs to be visible in the service consumer(s) backing cf orgs.  

You may choose to use common-broker-scripts on the osb-reverse-proxy to make the 3rd party's osb-reverse-proxy service plans visible to the master-depls service consummer backing cf orgs

See [common-broker-scripts/README.md#service-plan-visibility](../../../coab-depls/common-broker-scripts/README.md#service-plan-visibility)

#### Set up osb-cmdb OSB smoke test

Validate that the service provider service offerings are indeed visible in the catalog of each service consummers' osb-cmdb

Possibly configure the service consummers' osb-cmdb smoke test to instianciate the service provider's service offering.

See [common-broker-scripts/README.md#service-instance-and-service-key-provisionning](../../../coab-depls/common-broker-scripts/README.md#service-instance-and-service-key-provisionning)

Note: it is not currently supported to test multiple service offerings in osb smoke tests, so this configuration may be transient. See https://github.com/orange-cloudfoundry/paas-templates/issues/1015 for more details.

#### Validate usage of 3rd party service from osb service consummers

Manually validate that the 3rd party service offerings can now be consummed by authorized service consummers.

This use case is not yet automated by paas-templates, see https://github.com/orange-cloudfoundry/paas-templates/issues/1034

### Adding a new paas-templates service broker

Paas-templates service brokers are directly reacheable by master-depls/cf through internal routes. Consequently, no osb-reverse-proxy is deployed for paas-templates backed service broker.

For coab-based service offerings, the common-broker-scripts may be used to register coab broker and manage service plan visibility.

Refer to the steps described for 3rd party service broker. 

### Configuring quota per osb service consumer

These use-cases are not yet automated by paas-templates, this is tracked in https://github.com/orange-cloudfoundry/paas-templates/issues/37

#### Assigning quota to a given osb client

```
cf create-quota osb-cmdb-client-1-quota -s 2 --allow-paid-service-plans
cf set-quota osb-cmdb-services-org-client-1 osb-cmdb-client-1-quota
```

#### Tracking quota usage

```
$ cf org osb-cmdb-services-org-client --guid
59a49ee4-637b-443c-b339-99bf07ce2f81
$ cf curl v2/organizations/59a49ee4-637b-443c-b339-99bf07ce2f81/summary
{
   "guid": "59a49ee4-637b-443c-b339-99bf07ce2f81",
   "name": "osb-cmdb-services-org-client",
   "status": "active",
   "spaces": [
      {
         "guid": "562ea356-be9c-40f1-a1d2-34cf463f0234",
         "name": "p-mysql",
         "service_count": 2,
         "app_count": 0,
         "mem_dev_total": 0,
         "mem_prod_total": 0
      }
   ]
}

$cf quota osb-cmdb-client-1-quota
Getting quota osb-cmdb-client-1-quota info as xx...
OK
                       
Total Memory           0
Instance Memory        unlimited
Routes                 0
Services               2
Paid service plans     allowed
App instance limit     unlimited
Reserved Route Ports   0

```


## Contributing to osb-cmdb in paas-templates

### Updating symlinked instances

The [symlink-osb-cmdb-files.bash](./symlink-osb-cmdb-files.bash) will update all instances, and trigger CI exec of the the canoncial template instance 
