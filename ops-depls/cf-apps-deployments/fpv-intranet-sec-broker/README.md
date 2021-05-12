
# Overview

This deployment contains 
* a [static-creds-broker](./template/internet-broker_manifest-tpl.yml) returning static credentials to a http proxy
* a [sec-group-broker-filter](./template/internet-sec-broker_manifest-tpl.yml) which dynamically opens security groups to app bound to the service. Depends on the static-cred-broker to be reacheable from its OSB API endpoint (not accessed through CF APIs) 

# How to test

```
$ cf t -o system_domain
$ cf delete-space fpv-brokers
```

Manually launch pipelines in the following orders and check they become green
* /ops-depls-cf-apps-generated/jobs/cf-push-internet-broker 
* /ops-depls-cf-apps-generated/jobs/cf-push-internet-sec-broker 

Register the service broker in `master-depls/cf` by launching the `ops-depls-bosh-generated/jobs/check-terraform-consistency/` pipeline

Manually push a app and bind it to the service. Check security groups are dynamically opened

# Access actuator endpoint to check sec-group-broker version
 

```
# Lookup credentials
cf t -o system_domain -s fpv-brokers
cf env intranet-proxy-sec-group-broker-filter

# access actuator endpoint to check version
curl -u redacted-user:redacted-password  https://intranet-proxy-sec-group-broker-filter.redacted-domain.org/actuator/info | jq
```

