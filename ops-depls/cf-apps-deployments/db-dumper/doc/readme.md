# DB-DUMPER-SERVICE deployment

## Overview


db-dumper-service is a Cloud Foundry service broker to dump and restore databases on demand.

## Summary sheet

| Item | Value |
| -- | :--: |
| Type | CF Application  |
| Depends on | [db-dumper-service](https://github.com/orange-cloudfoundry/db-dumper-service) |
| Uses of | NA |
| Vars files | NA |
| Ops files | NA |



## How to use it

It can be used without a CF cli (docs: [db-dumper-service](https://github.com/orange-cloudfoundry/db-dumper-service) )

It is more  convenient to use the db-dumper-cli-plugin (docs:[db-dumper-cli-plugin](https://github.com/orange-cloudfoundry/db-dumper-cli-plugin)).



## Tips

If you want to use the db-dumper-cli-plugin, you can install it using the command below:

``
cf install-plugin https://github.com/orange-cloudfoundry/db-dumper-cli-plugin/releases/download/v1.4.2/db-dumper_linux_amd64 -f
``


## See also

* [db-dumper-cli-plugin](https://github.com/orange-cloudfoundry/db-dumper-cli-plugin)
* [db-dumper-service](https://github.com/orange-cloudfoundry/db-dumper-service)

## To do

N/A

