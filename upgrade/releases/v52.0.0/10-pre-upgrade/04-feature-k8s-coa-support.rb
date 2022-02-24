#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def feature_k8s_coa_support(secrets_dir)
  set_k8s_config_repo(secrets_dir)
  activate_pipeline(secrets_dir)
end

def add_default_value(git_config_yaml, k8s_key, default_value = Upgrade::USER_VALUE_REQUIRED)
  updated = false
  k8s_config_data = git_config_yaml.dig(k8s_key)
  if !k8s_config_data
    puts "Automatically set a valid value for '#{k8s_key}'"
    git_config_yaml[k8s_key] = default_value
    updated = true
  else
    puts "Ensure '#{k8s_key}' value hold expected value"
  end
  updated
end

def set_k8s_config_repo(secrets_dir)
  puts "Processing #{__method__.to_s}"
  update_required = false

  coa_config = Upgrade::CoaConfig.new(secrets_dir)
  git_config_yaml = coa_config.load_credentials(:git_config)
  
  %w[k8s-configs-repository-uri k8s-configs-repository-username k8s-configs-repository-password k8s-configs-repository-branch].each do |k8s_key|
    default_value = case k8s_key
    when 'k8s-configs-repository-username'
      '(('+'concourse_git_secrets_user))'
    when 'k8s-configs-repository-password'
      '((' + 'concourse_git_secrets_password))'
    when 'k8s-configs-repository-uri'
      'https://((' + 'concourse_git_secrets_user)):((' + 'concourse_git_secrets_password))@gitlab-gitlab-k8s.(('+ 'cloudfoundry_ops_domain))/paas_templates_group/gitops-fluxcd-repo.git'
    when 'k8s-configs-repository-branch'
      'master'
    else
      Upgrade::USER_VALUE_REQUIRED
    end
    update_required = add_default_value(git_config_yaml, k8s_key, default_value) || update_required
  end
  coa_config.write_yaml_credentials(:git_config, git_config_yaml) if update_required
end

def activate_pipeline(secrets_dir)
  puts "Processing #{__method__.to_s}"

  %w[micro-depls master-depls coab-depls].each do |root_deployment_name|
    ci_deployment_overview = Upgrade::CiDeploymentOverview.new(root_deployment_name, secrets_dir)
    pipelines_activation = Upgrade::CiDeploymentOverviewPipelineActivation.new( root_deployment_name, ci_deployment_overview.load.dig('ci-deployment',root_deployment_name,'pipelines'))
    if !pipelines_activation.active_pipeline_names.include?("#{root_deployment_name}-k8s-generated")
      pipelines_activation.activate_k8s_pipelines
      ci_deployment_overview.update_pipeline(pipelines_activation.pipelines)
      ci_deployment_overview.update
    else
      puts "K8s pipeline already active for #{root_deployment_name}"
    end
  end
end

config_path = ARGV[0]
puts config_path

feature_k8s_coa_support(config_path)
