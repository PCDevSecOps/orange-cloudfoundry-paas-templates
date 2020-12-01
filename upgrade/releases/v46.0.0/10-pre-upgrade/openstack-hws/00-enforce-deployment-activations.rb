#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../../lib/upgrade'


class OpenstackActivationEnforcer < Upgrade::BaseActivationEnforcer

  def enable_micro_depls
  micro_depls_deployments = %w[
    internet-relay
  ]
  micro_depls.enable_deployments(micro_depls_deployments)
  end
  def disable_micro_depls
    micro_depls_deployments = %w[ ] # No specific activation on openstack in v44.0.0
    micro_depls.disable_deployments(micro_depls_deployments)
  end
  def micro_depls_pipelines
    # No specific activation on openstack in v44.0.0
  end


  def enable_master_depls
    master_depls_deployments = %w[
        cf-autoscaler
        cf-internet-rps
        isolation-segment-internet
        isolation-segment-intranet-2
        logsearch
      ]
    master_depls.enable_deployments(master_depls_deployments)
  end
  def disable_master_depls
    master_depls_deployments = %w[ ] # No specific activation on openstack in v44.0.0
    master_depls.disable_deployments(master_depls_deployments)
  end
  def master_depls_pipelines
    # No specific activation on openstack in v44.0.0
  end


  def enable_ops_depls
    enabled_ops_deployments = %w[
        cassandra
    ]
    ops_depls.enable_deployments(enabled_ops_deployments)
  end
  def disable_ops_depls
    ops_deployments = %w[ ] # No specific activation on openstack in v46.0.0
    ops_depls.disable_deployments(ops_deployments)
  end
  def ops_depls_pipelines

  end
  def ops_depls_cf_apps
    enabled_ops_cf_apps = %w[
        cf-autoscaler-sample-app
        cf-networking-sample-app
        fpv-intranet-sec-broker
        guardian-uaa-broker-cf
        huawei-cloud-osb
        huawei-cloud-osb-sample-app
        postgresql-docker-broker
        postgresql-docker-test-app
        probe-internet
        probe-intranet
        pwm
        sec-group-broker-filter-cf
        smtp-sec-broker
      ]
    ops_depls.enable_cf_app_deployments(enabled_ops_cf_apps)
  end

  def enable_coab_depls
    coab_deployments = %w[
      cassandra
    ]
    coab_depls.enable_deployments(coab_deployments)
  end
  def disable_coab_depls
    coab_deployments = %w[
      cf-rabbit
    ]
    coab_depls.disable_deployments(coab_deployments)
  end
  def enable_coab_depls_cf_apps
    coab_cf_apps = %w[
      coa-cassandra-broker
      coa-cf-mysql-broker
      coa-mongodb-broker
      coa-redis-broker
    ]
    coab_depls.enable_cf_app_deployments(coab_cf_apps)
  end
  def disable_coab_depls_cf_apps
    coab_cf_apps = %w[
      coa-cf-rabbit-broker
    ]
    coab_depls.disable_cf_app_deployments(coab_cf_apps)
  end


  def coab_depls_ci_overview
    # Nothing specific in v44.0.0
  end

  def enable_kubo_depls
   #TODO
  end
  def disable_kubo_depls
   #TODO
  end
  def kubo_depls_pipelines
   #TODO
  end

  def other_root_deployment_operations
    enforce_cloudflare_ci_deployment_overview
  end

  def enforce_cloudflare_ci_deployment_overview
    root_deployment_name = 'cloudflare-depls'
    ci_deployment_overview = Upgrade::CiDeploymentOverview.new(root_deployment_name, @config_path)
    pipelines_activation = Upgrade::CiDeploymentOverviewPipelineActivation.new( root_deployment_name, ci_deployment_overview.load.dig('ci-deployment',root_deployment_name,'pipelines'))
    pipelines_activation.activate
    pipelines_activation.activate_pipeline('tf', root_deployment_name)
    ci_deployment_overview.target_name
    ci_deployment_overview.enable_terraform
    ci_deployment_overview.update_pipeline(pipelines_activation.pipelines)
    ci_deployment_overview.update
  end
end


config_path = ARGV[0]
OpenstackActivationEnforcer.new(config_path).run

