#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def feature_add_tag_release_on_all_bosh_deployments(config_path)
  update_required = false
  coa_config = Upgrade::CoaConfig.new(config_path)
  active_profiles = coa_config.load_credentials(:profiles) || {}

  profiles_value = active_profiles.dig('profiles') || ""
  profiles_list = profiles_value.split(',')

  %w(51-switch-to-k8s-jcr-for-docker-k3s 51-switch-to-k8s-minio 51-switch-internet-proxy 51-switch-intranet-proxy 51-switch-to-k8s-openldap 51-switch-to-k8s-traefik).each do |deprecated_profiles|
    if profiles_list.include?(deprecated_profiles)
      puts "Removing profile #{deprecated_profiles}"
      update_required = true
      profiles_list.delete(deprecated_profiles)
    else
      puts "Profile #{deprecated_profiles} already removed"
    end
  end

  active_profiles['profiles'] = profiles_list.sort.join(',')
  coa_config.write_yaml_credentials(:profiles, active_profiles) if update_required
  update_required
end


config_path = ARGV[0]
puts config_path

feature_add_tag_release_on_all_bosh_deployments(config_path)