#Metabase deployment
 

## Overview

The purpose of this deployment is to instantiate a metabase instance with its database : 

```plantuml

[Metabase] - [postgresql]

```
 
## Migration procedure
If you have tp migrate an old instance of metabase using h2 file to a new instance of metabase using postgres regards the fact that both instance belong to 2 bosh deployment.


Different steps describe here will consist in :
 - get h2 file from old metabase and copy it into new metabase instance
 - upgrade this file to the current version of metabase schema
 - empty the postgres db 
 - import data into postgres instance

### backup h2 file from old metabase 
```
bosh ssh metabase
sudo -i
monit stop metabase
cd /var/vcap/store
tar cvf backup-metabase.tgz metabase
```

### deploy metabase with concourse

as usually do by concourse process :-)


### copy metabase backup into vm

```
bosh scp backup-metabase.tgz metabase:/tmp/.
```

### upload and untar archive 
_- from bosh director connect to metabase_
```
  bosh ssh metabase \
  sudo -i \
  cd /tmp \
  tar -xvf backup-h2.tgz 
  ```


### stop current metabase

 ```
 cd /var/vcap/packages/metabase
 monit stop metabase
```
### change env variable to not use postgres anymore and reuse h2 

```
 unset MB_DB_PASS
 unset MB_DB_PORT
 unset MB_DB_HOST
 export MB_DB_TYPE=h2
 export MB_DB_FILE=/tmp/metabase/metabase.db

 /var/vcap/packages/openjdk/bin/java -jar metabase.jar 
```

It will update the current h2 base file to new version of metabase.
This step is mandatory if old metabase instance version is not the same as the new one.

### Empty the postgres database

from bosh director connect to db :
```
bosh ssh data_db
export PATH=$PATH:/var/vcap/packages/postgres-9.6.6/bin
```

connect to the base
```
psql -U admin metabase
```
execute script sql 

```
SELECT
    'drop table if exists "' || tablename || '" cascade;' as pg_drop
FROM
    pg_tables
WHERE
    schemaname='public';
``` 
copy/past and execute result of sql script to drop all tables

you can verify that by watching the number of table command :
```
\dq
```
you should'nt have any table.

### Migrate h2 to postgres
do from metabase vm 
```
cd /var/vcap/jobs/metabase/config/
. setenv.sh
/var/vcap/packages/openjdk/bin/java -jar metabase.jar load-from-h2 /tmp/metabase/metabase.db

monit start metabase
```
After few minutes, job is done.


