The overview broker (see https://github.com/mattmcneeney/overview-broker) is a sample OSB broker which captures incoming OSB calls. This is useful in asserting the current CF behavior w.r.t. OSB brokers.

### Manual platform ops steps

Steps below describe the activation and registration of broker in system_domain organization. They are optional.

In secrets repo 
```bash
mkdir -p ./ops-depls/cf-apps-deployments/overview-broker/secrets
cat << EOF > ./ops-depls/cf-apps-deployments/overview-broker/enable-cf-app.yml
cf-app:
  overview-broker:
    cf_api_url: https://api.((cloudfoundry_system_domain))
    cf_username: coa-cf # credential_leak_validated
    cf_password: ((coa_cf_password)) #find from /concourse-micro/main name space
    cf_organization: system_domain
    cf_space: overview-broker
EOF
git add ./ops-depls/cf-apps-deployments/overview-broker/enable-cf-app.yml

cat << EOF > ./ops-depls/cf-apps-deployments/overview-broker/secrets/secrets.yml
secrets:
#  debug: false # turn post-deploy debug traces
#  debug: true # turn post-deploy debug traces
  register_broker_enabled: true
  register_broker_services: "overview-service"
  # Note that overview-broker's plans are not enabled in osb-cmdb-backend-services-org-client-1 
  # Instead, osb-reverse-proxy-1's plans with overview-service are enabled in osb-cmdb-backend-services-org-client-1
  enable_services_in_orgs: "system_domain osb-cmdb-backend-services-org-client-0 osb-cmdb-backend-services-org-client-5" # org used in smoke tests is automatically added to this list
  
  smoke_test_service: "overview-service" #name of the service to instanciate in smoke tests
  smoke_test_service_plan: "large"    #name of the service plan to instanciate in smoke tests

  overview-broker: # should be matching deployment name
EOF
git add ./ops-depls/cf-apps-deployments/overview-broker/secrets/secrets.yml

git commit -m "enabling overview broker as described in step feature-overview-broker"
```

The concourse pipeline will register the service in master-depls/cf if above requested

Test the service (this is also performed by the smoke test )
```bash
log-credhub
log-cf
cf target -o system_domain -s overview-broker
cf cs overview-service small my-service
cf service my-service
# Browse to displayed dashboard, e.g. https://overview-broker.$(credhub-get /secrets/cloudfoundry_system_domain)/dashboard 
firefox https://overview-broker.$(credhub-get /secrets/cloudfoundry_system_domain)/dashboard
```

display the catalog (including json schema)
```
curl -k -u  admin:password -H "x-broker-api-version":"2.14" https://overview-broker.$(credhub-get /secrets/cloudfoundry_system_domain)/v2/catalog | jq
```
