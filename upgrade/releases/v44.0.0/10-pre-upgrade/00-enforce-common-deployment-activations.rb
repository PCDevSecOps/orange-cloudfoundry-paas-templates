#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

class CommonEnforcer < Upgrade::BaseActivationEnforcer
  def enable_micro_depls
    micro_depls_deployments = %w[
      bosh-master
      cfcr cfcr-addon cfcr-persistent-worker concourse credhub-ha credhub-seeder
      dns-recursor docker-bosh-cli
      gitlab
      internet-proxy
      minio-private-s3
      nexus
      prometheus-exporter-master
    ]
    micro_depls.enable_deployments(micro_depls_deployments)
  end
  def disable_micro_depls
    micro_depls_deployments = %w[
      ntp
    ]
    micro_depls.disable_deployments(micro_depls_deployments)
  end
  def micro_depls_pipelines
    # Nothing shared in v44
  end
  def micro_depls_ci_overview
    root_deployment_name = 'micro-depls'
    ci_deployment_overview = Upgrade::CiDeploymentOverview.new(root_deployment_name, @config_path)
    pipelines_activation = Upgrade::CiDeploymentOverviewPipelineActivation.new( root_deployment_name, ci_deployment_overview.load.dig('ci-deployment',root_deployment_name,'pipelines'))
    pipelines_activation.activate
    pipelines_activation.activate_bosh_pipelines
    pipelines_activation.activate_concourse_pipelines
    ci_deployment_overview.target_name
    ci_deployment_overview.enable_terraform
    ci_deployment_overview.update_pipeline(pipelines_activation.pipelines)
    ci_deployment_overview.update
  end


  def enable_master_depls
    master_depls_deployments = %w[
      bosh-coab
      bosh-ops
      cf
      cfcr
      cfcr-addon
      cfcr-persistent-worker
      cloudfoundry-datastores
      intranet-interco-relay
      isolation-segment-intranet-1
      logsearch-ops
      metabase
      openldap
      ops-routing
      osb-routing
      prometheus
      prometheus-exporter-coab
      prometheus-exporter-ops
      shield
      weave-scope
    ]
    master_depls.enable_deployments(master_depls_deployments)

  end
  def disable_master_depls
    master_depls_deployments = %w[
      prometheus-exporter-kubo
    ]
    master_depls.disable_deployments(master_depls_deployments)
  end
  def master_depls_pipelines
    pipelines = %w[
      cached-buildpack-pipeline
    ]
    master_depls.enable_deployments(pipelines)
  end
  def master_depls_ci_overview
    root_deployment_name = 'master-depls'
    ci_deployment_overview = Upgrade::CiDeploymentOverview.new(root_deployment_name, @config_path)
    pipelines_activation = Upgrade::CiDeploymentOverviewPipelineActivation.new( root_deployment_name, ci_deployment_overview.load.dig('ci-deployment',root_deployment_name,'pipelines'))
    pipelines_activation.activate
    pipelines_activation.activate_bosh_pipelines
    pipelines_activation.activate_concourse_pipelines
    ci_deployment_overview.target_name
    ci_deployment_overview.enable_terraform
    ci_deployment_overview.update_pipeline(pipelines_activation.pipelines)
    ci_deployment_overview.update
  end


  def enable_ops_depls
    ops_deployments = %w[
      cf-rabbit37
    ]
    ops_depls.enable_deployments(ops_deployments)
  end
  def disable_ops_depls
    ops_deployments = %w[
      admin-ui
    ]
    ops_depls.disable_deployments(ops_deployments)
  end
  def ops_depls_pipelines
    # Nothing in v44
  end
  def ops_depls_cf_apps
    enabled_ops_cf_apps = %w[
      admin-ui
      intranet-sec-broker
      stratos-ui-v2
    ]
    ops_depls.enable_cf_app_deployments(enabled_ops_cf_apps)

    disabled_ops_cf_apps = %w[
      app-with-metrics-influxdb
      cf-webui
    ]
    ops_depls.disable_deployments(disabled_ops_cf_apps)
  end
  def ops_depls_ci_overview
    root_deployment_name = 'ops-depls'
    ci_deployment_overview = Upgrade::CiDeploymentOverview.new(root_deployment_name, @config_path)
    pipelines_activation = Upgrade::CiDeploymentOverviewPipelineActivation.new( root_deployment_name, ci_deployment_overview.load.dig('ci-deployment',root_deployment_name,'pipelines'))
    pipelines_activation.activate
    pipelines_activation.activate_bosh_pipelines
    pipelines_activation.activate_concourse_pipelines
    pipelines_activation.activate_cf_apps_pipelines
    ci_deployment_overview.target_name
    ci_deployment_overview.enable_terraform(File.join(root_deployment_name, 'cloudfoundry', 'terraform-config'))
    ci_deployment_overview.update_pipeline(pipelines_activation.pipelines)
    ci_deployment_overview.update
  end


  def enable_coab_depls
    coab_deployments = %w[ ] # No specific activation on openstack in v44.0.0
    coab_depls.enable_deployments(coab_deployments)
  end
  def disable_coab_depls
    coab_deployments = %w[
      cf-rabbit
    ]
    coab_depls.disable_deployments(coab_deployments)
  end
  def coab_depls_pipelines
    # No specific activation on openstack in v44.0.0
  end
  def coab_depls_cf_apps
    disabled_coab_cf_apps = %w[
      coa-cf-rabbit-broker
    ]
    coab_depls.disable_cf_app_deployments(disabled_coab_cf_apps)
  end
  def coab_depls_ci_overview
    root_deployment_name = 'coab-depls'
    ci_deployment_overview = Upgrade::CiDeploymentOverview.new(root_deployment_name, @config_path)
    pipelines_activation = Upgrade::CiDeploymentOverviewPipelineActivation.new( root_deployment_name, ci_deployment_overview.load.dig('ci-deployment',root_deployment_name,'pipelines'))
    pipelines_activation.activate
    pipelines_activation.activate_bosh_pipelines
    pipelines_activation.activate_cf_apps_pipelines
    ci_deployment_overview.target_name
    ci_deployment_overview.enable_terraform
    ci_deployment_overview.update_pipeline(pipelines_activation.pipelines)
    ci_deployment_overview.update
    ci_deployment_overview.add_default_auto_init_credentials
  end


  def enable_kubo_depls

  end
  def disable_kubo_depls

  end
  def kubo_depls_pipelines

  end
end

config_path = ARGV[0]
CommonEnforcer.new(config_path).run

