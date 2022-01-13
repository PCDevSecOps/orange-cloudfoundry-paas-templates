#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

class CommonEnforcer < Upgrade::BaseActivationEnforcer
  def enable_micro_depls
    micro_depls_deployments = %w[
      00-core-connectivity-terraform 00-core-connectivity-k8s 00-gitops-management
      01-ci-k8s
      k8s-gitlab
      bosh-master
      concourse credhub-ha credhub-seeder
      dns-recursor docker-bosh-cli
      internet-proxy
      ops-routing
      inception
    ]
    micro_depls.enable_deployments(micro_depls_deployments)
  end
  def disable_micro_depls
    micro_depls_deployments = %w[
      gitlab
      jcr
      minio-private-s3
      prometheus-exporter-master
    ]
    micro_depls.disable_deployments(micro_depls_deployments)
  end
  def micro_depls_pipelines
    enable_pipelines = %w[
      retrigger-all-deployments
    ]
    micro_depls.enable_deployments(enable_pipelines)
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
      cloudfoundry-datastores
      intranet-interco-relay
      isolation-segment-intranet-1
      logsearch-ops
      metabase
      ops-routing
      osb-routing
      prometheus
      prometheus-exporter-coab
      weave-scope
      isolation-segment-internal
    ]
    master_depls.enable_deployments(master_depls_deployments)

  end
  def disable_master_depls
    master_depls_deployments = %w[
      shield
      openldap
      prometheus-exporter-ops
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
      cf-rabbit-osb
      mongodb-osb
      cf-redis-osb
      cloudfoundry-mysql-osb
      cloudfoundry-mysql-osb-region-2
    ]
    ops_depls.enable_deployments(ops_deployments)
  end
  def disable_ops_depls
    ops_deployments = %w[
      admin-ui
      cf-rabbit37
    ]
    ops_depls.disable_deployments(ops_deployments)
  end
  def ops_depls_pipelines
    enable_pipelines = %w[
      recurrent-tasks
    ]
    ops_depls.enable_deployments(enable_pipelines)
  end
  def ops_depls_cf_apps
    enabled_ops_cf_apps = %w[
      admin-ui
    ]
    ops_depls.enable_cf_app_deployments(enabled_ops_cf_apps)

    disabled_ops_cf_apps = %w[
    ]
    ops_depls.disable_deployments(disabled_ops_cf_apps)

    destroyed_ops_cf_apps = %w[
      stratos-ui-v2
    ]
    ops_depls.destroy_cf_app_deployments(destroyed_ops_cf_apps)
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
      01-cf-mysql-extended
      02-redis-extended
      03-cf-rabbit-extended
      04-mongodb-extended
      20-strimzi-kafka
      cf-mysql
      cf-rabbit
      mongodb
      redis
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
      coa-cf-mysql-broker
      coa-cf-mysql-extended-broker
      coa-cf-rabbit-broker
      coa-cf-rabbit-extended-broker
      coa-mongodb-broker
      coa-mongodb-extended-broker
      coa-redis-broker
      coa-redis-extended-broker
      coa-strimzi-broker
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
    pipelines_activation.activate_concourse_pipelines
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
CommonEnforcer.new(config_path).run

