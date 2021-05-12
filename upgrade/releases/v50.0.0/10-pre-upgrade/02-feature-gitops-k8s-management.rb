#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def add_missing_backup_profile(config_path)
  coa_config = Upgrade::CoaConfig.new(config_path)
  active_profiles = coa_config.load_credentials(:profiles) || {}

  active_profiles['profiles-comment'] = <<~YAML
      Mandatory. List active profiles (comma separated list without spaces)- Example: profile-1,profile-2
      Default: empty
  YAML

  profiles_value = active_profiles.dig('profiles') || ""
  profiles_list = profiles_value.split(',')
  unless profiles_list.include?("60-enable-backups")
    update_required = true
    profiles_list << "60-enable-backups"
    active_profiles['profiles'] = profiles_list.sort.join(',')
  else
    puts "Profiles already uptodate"
  end

  coa_config.write_yaml_credentials(:profiles, active_profiles) if update_required
  update_required
end

def disable_stratos_cf_app(config_path)
  stratos_cf = Upgrade::CfAppDeployment.new("stratos-ui-v2", "ops-depls", config_path)
  stratos_cf.destroy
end

def enable_gitops_management(config_path)
  gitops_management = Upgrade::Deployment.new("00-gitops-management", "micro-depls", config_path)
  gitops_management.enable
end

def feature_gitops_k8s_management(config_path)
  puts "Processing #{__method__.to_s}"

  add_missing_backup_profile(config_path)
  disable_stratos_cf_app(config_path)
  enable_gitops_management(config_path)
end


config_path = ARGV[0]
puts config_path

feature_gitops_k8s_management(config_path)