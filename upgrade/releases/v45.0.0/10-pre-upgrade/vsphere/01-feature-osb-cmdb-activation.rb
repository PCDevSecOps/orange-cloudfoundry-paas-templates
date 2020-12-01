#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../../lib/upgrade'

def list_osb_cmdb_brokers
  %w[osb-cmdb-broker-0 osb-cmdb-broker-1 osb-cmdb-broker-2 osb-cmdb-broker-3 osb-cmdb-broker-4]
end

def secrets_template(name, org_suffix = '')
  org_suffix = name.split('-').last  if org_suffix.to_s.empty?

  <<~YAML
  secrets:
    mode: release
    register_broker_enabled: true
    register_broker_services: "p-mysql noop-ondemand"
    enable_services_in_orgs: "system_domain" # org used in smoke tests is automatically added to this list
    broker_name: #{name} #name of the broker registered in marketplace
    smoke_test_org: osb-cmdb-smoke-test-brokered-services-org-client-0 # org to be used by smoke tests. Will be created if missing
    smoke_test_service: p-mysql #name of the service to instanciate in smoke tests
    smoke_test_service_plan: 10mb    #name of the service plan to instanciate in smoke tests
    osb-cmdb-broker:
      name: user # broker basic auth user name
      # Default org and space are used to dynamically generate catalog, and provision backend services.
      # Warning: overlapping service names among registered service brokers are not supported in default org.
      default-org: osb-cmdb-backend-services-org-client-#{org_suffix} # Should be available. Paas-templates will create it automatically if create-default-org is set to true
      default-space: default # Should be available. Paas-templates will create it automatically if create-default-org is set to true
      create-default-org: true # Whether default org and default space should be created if missing
  YAML
end

def meta_yml
  <<~YAML
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
  YAML
end



def osb_cmdb_activation(config_dir)
  puts "Processing #{__method__.to_s}"

  ops_depls = Upgrade::RootDeployment.new('ops-depls',config_dir)
  ops_depls.enable_cf_app_deployments(list_osb_cmdb_brokers)
  raw_content = true
  list_osb_cmdb_brokers.each do |app_name|
    cf_app_deployment = Upgrade::CfAppDeployment.new(app_name, 'ops-depls', config_dir)
    cf_app_deployment.create_local_secrets(secrets_template(app_name), raw_content)
    cf_app_deployment.create_local_meta(meta_yml, raw_content)
  end
end


config_path = ARGV[0]
puts config_path

osb_cmdb_activation(config_path)
