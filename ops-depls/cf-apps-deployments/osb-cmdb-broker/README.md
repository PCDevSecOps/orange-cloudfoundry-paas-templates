Osb-Cmdb provides a single OSB exposition endpoint for all brokers

See https://github.com/orange-cloudfoundry/paas-templates/issues/492 and https://github.com/orange-cloudfoundry/osb-cmdb-spike for more details.

## Usage

- Handles credhub secret generation, broker registration, service plan visibility
and smoke test execution.
- Jar is downloaded from circleci in tarball mode or github in release node,
   preprocessed to replace application.yml
- Smoke tests inject backing services assertion in common smoke tests
   - Asserts for DSI, CSK, DSK

### quota per osb client

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

### Instance per OSB client

There is one instance of Cmdb per Osb client (osb-cmdb-broker-0, ... osb-cmdb-broker-4).
* Per convention, osb-cmdb-broker-0 is dedicated to master-depls-cf osb client
* Per convention, the canoncial template instance (osb-cmdb-broker) is not enabled 

## Contributing

### Updating symlinked instances

The [symlink-osb-cmdb-files.bash](./symlink-osb-cmdb-files.bash) will update all instances, and trigger CI exec of the the canoncial template instance 


$ cf m
Getting services from marketplace in org service-sandbox / space osb-cmdb-broker-0-smoke-tests as xx...
OK
service        plans          description          broker
p-mysql-cmdb   10mb, 20mb     A useful service     osb-cmdb-broker
p-mysql-cmdb   10mb, 20mb     A useful service     osb-cmdb-broker-0
