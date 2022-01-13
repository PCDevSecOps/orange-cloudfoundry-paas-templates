
<!-- TOC initiated with [gh-md-toc](https://github.com/ekalinin/github-markdown-toc) -->
<!--ts-->
   * [Overview](#overview)
      * [Instance per 3rd party service provider](#instance-per-3rd-party-service-provider)
   * [Common use-cases](#common-use-cases)
      * [Adding a new osb-reverse-proxy](#adding-a-new-osb-reverse-proxy)
         * [Enable a new osb-reverse-proxy  instance](#enable-a-new-osb-reverse-proxy--instance)
         * [Configure osb-reverse-proxy instance](#configure-osb-reverse-proxy-instance)
      * [Access osb-reverse-proxy OSB API logs](#access-osb-reverse-proxy-osb-api-logs)
   * [Operating osb-reverse-proxy](#operating-osb-reverse-proxy)
      * [Turn on verbose logging](#turn-on-verbose-logging)
   * [Contributing to osb-reverse-proxy in paas-templates](#contributing-to-osb-reverse-proxy-in-paas-templates)
      * [Updating symlinked instances](#updating-symlinked-instances)
<!--te-->

## Overview

Osb-reverse-proxy enables master-depls/cf to reach 3rd party brokers only exposed on intranet/internet

See https://github.com/orange-cloudfoundry/osb-reverse-proxy for more details.

### Instance per 3rd party service provider

There is one instance of osb-reverse-proxy per 3rd party service provider (osb-reverse-proxy-0, ... osb-reverse-proxy-4).
* Per convention, the canoncial template instance (osb-reverse-proxy) is not enabled 

## Common use-cases

### Adding a new osb-reverse-proxy 

#### Enable a new osb-reverse-proxy  instance

* Pick the next available index (say N) in the paas-templates/ops-depls/cf-apps-deployments/osb-reverse-proxy-* list
* Enable the cf app by creating through `secrets/ops-depls/cf-apps-deployments/osb-reverse-proxy-N/enable-cf-app.yml`

#### Configure osb-reverse-proxy instance

in secrets/ops-depls/cf-apps-deployments/osb-reverse-proxy-N/secrets/secrets.yml

```yaml
secrets:
#  debug: false # turn post-deploy debug traces
#  mode: release
#  mode: tarball
  register_broker_enabled: true
  register_broker_dangerously_purge_service_offerings: true #workaround for https://github.com/cloudfoundry/overview-broker/issues/71
  register_broker_services: "overview-service"
  enable_services_in_orgs: "system_domain" # org used in smoke tests is automatically added to this list
  broker_name: "osb-reverse-proxy-1" #name of the broker registered in marketplace
# hardcoded in templates
#  smoke_test_org: "service-sandbox" # org to be used by smoke tests. Will be created if missing
  smoke_test_service: "overview-service" #name of the service to instanciate in smoke tests
  smoke_test_service_plan: "small"    #name of the service plan to instanciate in smoke tests

  # defines a function to assert the create service instance
  # $1: service instance name
  # will fail on any non zero exit status, (eg. "false" command)
  # hint: configure your IDE to get shell completion in this block. See https://github.com/orange-cloudfoundry/paas-templates/issues/361
  assert_create_service_instance: |
    echo_header "asserting that the underlying broker (assuming overview-broker from paas-templates) recorded OSB calls were proxied by intranet proxy"
    ...

  osb-reverse-proxy-1: # should be matching deployment name
    name: "admin"  # broker basic auth user name. Overview service has hardcoded user/namepassword. See paas-templates/ops-depls/cf-apps-deployments/overview-broker/README.md
    password: "redacted_password" # Deprecated, moved to credhub. Overview service has hardcoded user/namepassword. See paas-templates/ops-depls/cf-apps-deployments/overview-broker/README.md
    http_proxy: # proxy used by osb-reverse-proxy to reach backing service broker.
      # In the case of overview-service, we reach it from intranet proxy
      host: "intranet-http-proxy.internal.paas"
      port: "3129"
    backendBrokerUri: https://overview-broker.redacted-domain.org
```

configure meta.yml

```yaml
meta:
  osb-reverse-proxy:
    # overrides application-cloud.yml in the osb-cmdb.jar files
    # should not be required in most cases
    application_yml:
# This should be spring or spring-cloud-gateway configuration
# See https://cloud.spring.io/spring-cloud-gateway/reference/html/#configuring-route-predicate-factories-and-gateway-filter-factories
      
#Below is an example of skipping TLS certs
#      spring:
#        cloud:
#          gateway:
#      
#            # https://cloud.spring.io/spring-cloud-gateway/reference/html/#tls-and-ssl
#            # ignore shield TLS cert for now
#            ssl:
#              useInsecureTrustManager: true
#
```

### Access osb-reverse-proxy OSB API logs

See [osb-reverse-proxy/README.md#osb-api-logs](https://github.com/orange-cloudfoundry/osb-reverse-proxy#osb-api-logs)

## Operating osb-reverse-proxy

### Turn on verbose logging

See ops-depls/cf-apps-deployments/osb-reverse-proxy/template/osb-reverse-proxy_manifest-tpl.yml section SPRING_PROFILES_ACTIVE for documentation on how to turn on verbose logging for troubleshooting purposes.


## Contributing to osb-reverse-proxy in paas-templates

### Updating symlinked instances

The [symlink-osb-reverse-proxy-files.bash](./symlink-osb-reverse-proxy-files.bash) will update all instances, and trigger CI exec of the the canoncial template instance 


$ cf m
Getting services from marketplace in org service-sandbox / space osb-reverse-proxy-0-smoke-tests as xx...
OK
service        plans          description          broker
p-mysql-cmdb   10mb, 20mb     A useful service     osb-reverse-proxy
p-mysql-cmdb   10mb, 20mb     A useful service     osb-reverse-proxy-0
