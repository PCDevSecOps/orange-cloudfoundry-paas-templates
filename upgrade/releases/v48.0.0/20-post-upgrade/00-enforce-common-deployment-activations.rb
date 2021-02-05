#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

class K8SCommonEnforcer < Upgrade::BaseActivationEnforcer
  def enable_micro_depls
    micro_depls_deployments = %w[
      k8s-addon
      k8s-traefik
      k8s-jaeger
      k8s-openebs
      k8s-longhorn
      k8s-logging
      k8s-prometheus
    ]
    micro_depls.enable_deployments(micro_depls_deployments)
  end
  def disable_micro_depls
    micro_depls_deployments = %w[
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
      k8s-addon
      k8s-traefik
      k8s-jaeger
      k8s-openebs
      k8s-longhorn
      k8s-logging
      k8s-prometheus
      k8s-metabase
      k8s-grafana
    ]
    master_depls.enable_deployments(master_depls_deployments)

  end
  def disable_master_depls
    master_depls_deployments = %w[
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
    ]
    ops_depls.enable_deployments(ops_deployments)
  end
  def disable_ops_depls
    ops_deployments = %w[
    ]
    ops_depls.disable_deployments(ops_deployments)
  end
  def ops_depls_pipelines
    # Nothing in v44
  end
  def ops_depls_cf_apps
    enabled_ops_cf_apps = %w[
    ]
    ops_depls.enable_cf_app_deployments(enabled_ops_cf_apps)

    disabled_ops_cf_apps = %w[
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
    ci_deployment_overview.enable_terraform("#{root_deployment_name}/cloudfoundry/terraform-config")
    ci_deployment_overview.update_pipeline(pipelines_activation.pipelines)
    ci_deployment_overview.update
  end


  def enable_coab_depls
    coab_deployments = %w[
     10-k8s-addon
     10-k8s-traefik
     10-k8s-jaeger
     10-k8s-openebs
     10-k8s-longhorn
     10-k8s-logging
     10-k8s-prometheus
    ]
    coab_depls.enable_deployments(coab_deployments)
  end
  def disable_coab_depls
    coab_deployments = %w[
      bui
      shield
    ]
    coab_depls.disable_deployments(coab_deployments)
  end
  def enable_coab_depls_cf_apps
    coab_cf_apps = %w[
    ]
    coab_depls.enable_cf_app_deployments(coab_cf_apps)
  end
  def disable_coab_depls_cf_apps
    coab_cf_apps = %w[
    ]
    coab_depls.disable_cf_app_deployments(coab_cf_apps)
  end


  def coab_depls_pipelines
    # No specific activation in v46.0.0
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
    kubo_depls_deployments = %w[
    ]
    kubo_depls.disable_deployments(kubo_depls_deployments)
  end
  def kubo_depls_pipelines

  end
end

config_path = ARGV[0]
K8SCommonEnforcer.new(config_path).run

