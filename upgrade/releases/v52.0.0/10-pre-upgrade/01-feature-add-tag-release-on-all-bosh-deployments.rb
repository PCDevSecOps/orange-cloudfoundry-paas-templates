#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def feature_add_tag_release_on_all_bosh_deployments(config_path)
  coa_config = Upgrade::CoaConfig.new(config_path)
  active_profiles = coa_config.load_credentials(:profiles) || {}

  active_profiles['profiles-comment'] = <<~YAML
      Mandatory. List active profiles (comma separated list without spaces)- Example: profile-1,profile-2
      Default: empty
  YAML

  profiles_value = active_profiles.dig('profiles') || ""
  profiles_list = profiles_value.split(',')
  unless profiles_list.include?("91-paas-templates-version")
    update_required = true
    profiles_list << "91-paas-templates-version"
    active_profiles['profiles'] = profiles_list.sort.join(',')
  else
    puts "Profiles already uptodate"
  end

  coa_config.write_yaml_credentials(:profiles, active_profiles) if update_required
  update_required
end


config_path = ARGV[0]
puts config_path

feature_add_tag_release_on_all_bosh_deployments(config_path)