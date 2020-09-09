#Metabase configuration

This document is a guideline in order to setup a metabase instance with minimal configuration data (collections, cards and dashboard). 

## Overview

Before loading the configuration data, two actions must be performed : 

1. Create a new user account on metabase (url format is https://metabase-ops<ops_domain>). This account will be used in order to load data into metabase.

2. Connect to metabase and declare two data sources from Admin Panel (Databases) : 
    * A first data source which targets the cf cloudcontroller database
        *  Password is stored in credhub : credhub get --name "/secrets/cloudfoundry_ccdb_password"
    * A data source which targets the cf uaa database 
        *  Password is stored in credhub : credhub get --name "/secrets/cloudfoundry_uaadb_password"

## Pre-requisites

1. An Ubuntu local VM (16.04 or higher) (with curl) and docker installed
    * sudo apt install curl
    * https://docs.docker.com/install/linux/docker-ce/ubuntu/

2. Access to Internet
    * curl http://www.google.fr

3. Access to ops_domain
 
4. Clone of paas-templates available in your Ubuntu local VM (PAAS_TEMPLATES_HOME)

5. Dns information (DNS)
    * nmcli dev show | grep 'IP4.DNS'

## Files

Two files : 
1. appsettings.json : this file contains credential data (url, username and password).
    * Url : Metabase endpoint (depends on your target platform)
    * Username : Metabase username (choosen at user creation time)
    * Password : Metabase password (choosen at user creation time)

2. starter-dashboard.json : this file contains configuration data (collections, cards and dashboard).

## Export/import procedure in action

The steps are from your Ubuntu local VM :  

1. Go to metabase configuration directory
    * cd <PAAS_TEMPLATES_HOME>/master-depls/metabase/configuration

2. Amend the file appsettings.json with url, username and password
    * vi appsettings.json

3. Launch the docker image in order to export data (backup) -- see expected output for export
    * sudo docker run -it --name export --dns <DNS> -v `pwd`/appsettings.json:/app/appsettings.json elevate/elevate.metabase.tools  metabase-export.exe Command=export OutputFilename=metabase-state.json

4. Launch the docker image in order to import data -- see expected output for import
    * sudo docker run -it --dns <DNS> -v `pwd`/starter-dashboard.json:/app/starter-dashboard.json --volumes-from export elevate/elevate.metabase.tools metabase-import.exe Command=import InputFilename=starter-dashboard.json DatabaseMapping:2=2 DatabaseMapping:3=3

5. Clean useless containers
    * sudo docker container rm export

## Expected output for export

```
Exported current state for https://metabase-expe.<redacted_ops_domain>/ to metabase-state.json
```

## Expected output for import

```
Creating collections...
Creating collection 'services'
Creating collection 'Apps'
Deleting all dashboards...
Deleting all cards...
Creating cards...
Creating card 'Droplets, Count, Grouped by Build Pack Receipt Build Pack'
Creating card 'Events, Raw data'
Creating card 'Repartition of app desired state'
Creating card 'Count App Usage Events per day'
Creating card 'last known app state ?'
Creating card 'count App Usage Events per app'
Creating card 'Count of Apps'
Creating card 'mon nom'
Creating card 'How many users joined per months ?'
Creating card 'Cumulative count of Users in the platform'
Creating card 'count all service bindings per service'
Creating card 'service plans usage summary statistics'
Creating card 'service plans usage detailed statistics'
Creating card 'Cumulative count of Apps in the platform'
Creating card 'Count of Users'
Creating card 'How many Apps created per months ?'
Creating card 'Top 5 service plan usage in the platform'
Creating card 'Top 5 service usage in the platform'
Creating card 'cloudfoundry Users - from uaadb'
Creating card 'New CF user registrations (past week)'
Creating card 'CF user registrations (count since 30 days)'
Creating card 'New service brokers (since 30 days)'
Creating card 'New service brokers (count since 30 days)'
Creating card 'CF user registrations (since 30 days)'
Creating card 'app buildpacks'
Creating card 'orange-private-sandboxes service instances'
Creating card 'service plan usage by org (bindings)'
Creating card 'Service instances by Spaces'
Creating card 'Service instances by Organizations'
Creating card 'RAM used by Organizations'
Creating card 'RAM used by Spaces'
Creating card 'Applications using mySQL'
Creating card 'Applications using Mongodb'
Creating card 'Applications using Cassandra'
Creating card 'Applications using Cassandra'
Creating dashboards...
Creating dashboard 'CF apps'
Creating dashboard 'CF services dasboard'
Creating dashboard 'CF users'
Creating dashboard 'Weekly news'
Done importing
Done importing from starter-dashboard.json into https://metabase-expe.<redacted_ops_domain>/
```


