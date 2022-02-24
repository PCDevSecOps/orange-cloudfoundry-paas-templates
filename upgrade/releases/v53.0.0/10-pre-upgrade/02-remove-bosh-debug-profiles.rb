#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

DEBUG_PROFILE = %w[
99-debug-coab-depls
99-debug-k8s-coab-depls
99-debug-k8s-master-depls
99-debug-k8s-micro-depls
99-debug-master-depls
99-debug-ops-depls
99-debug-remote-r2-depls
99-debug-remote-r3-depls
].freeze  # This list can be updated using: find . -type d -name "99-*debug*" -exec basename {} \;|sort|uniq

def feature_remove_coab_debug_profile(config_path)
  coa_config = Upgrade::CoaConfig.new(config_path)
  active_profiles = coa_config.load_credentials(:profiles) || {}
  update_required = false
  profiles_value = active_profiles.dig('profiles') || ""
  profiles_list = profiles_value.split(',')

  DEBUG_PROFILE.each do |deprecated_profile|
    if profiles_list.include?(deprecated_profile)
      update_required = true
      profiles_list.delete_if { |profile_name| profile_name == deprecated_profile}
      active_profiles['profiles'] = profiles_list.sort.join(',')
      comments = active_profiles.dig('profiles-comment')||''
      active_profiles['profiles-comment'] = comments + "\nTo easily visualize active profiles, please run './dump-profiles.sh', collocated into this directory"
    else
      puts "Profiles already up-to-date (ie does not contain '#{deprecated_profile}' profile)"
    end
  end

  coa_config.write_yaml_credentials(:profiles, active_profiles) if update_required
  update_required
end


config_path = ARGV[0]
puts config_path

feature_remove_coab_debug_profile(config_path)