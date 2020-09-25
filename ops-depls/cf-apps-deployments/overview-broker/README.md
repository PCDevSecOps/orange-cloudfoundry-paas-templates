The overview broker (see https://github.com/mattmcneeney/overview-broker) is a sample OSB broker which captures incoming OSB calls. This is useful in asserting the current CF behavior w.r.t. OSB brokers.

### Manual platform ops steps

Steps below describe the activation and registration of broker in system_domain organization. They are optional.

In secrets repo 
```bash
mkdir -p ./ops-depls/cf-apps-deployments/overview-broker
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
git commit -m "enabling overview broker as described in step feature-overview-broker"
```

Register the service, as space scoped (to not pollute marketplace)

```bash
log-credhub
log-cf
cf target -o system_domain -s overview-broker
cf create-service-broker --space-scoped overview-broker admin password https://overview-broker.$(credhub-get /secrets/cloudfoundry_system_domain)
```

Enable visibility for the service in an additional org (e.g. to be used by osb-cmdb-0 tests)

```bash
# Review current service access
cf service-access  -b overview-broker
# Enable access to overview-service for use by osb-cmdb-0
cf enable-service-access overview-service -b overview-broker -o osb-cmdb-backend-services-org-client-0
```


Test the service
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
