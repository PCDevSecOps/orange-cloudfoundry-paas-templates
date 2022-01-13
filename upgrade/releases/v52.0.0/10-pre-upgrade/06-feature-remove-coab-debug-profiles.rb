#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

COAB_DEBUG_PROFILE = "99-debug-coab-depls".freeze

def feature_remove_coab_debug_profile(config_path)
  coa_config = Upgrade::CoaConfig.new(config_path)
  active_profiles = coa_config.load_credentials(:profiles) || {}

  profiles_value = active_profiles.dig('profiles') || ""
  profiles_list = profiles_value.split(',')
  if profiles_list.include?(COAB_DEBUG_PROFILE)
    update_required = true
    profiles_list.delete_if { |profile_name| profile_name == COAB_DEBUG_PROFILE}
    active_profiles['profiles'] = profiles_list.sort.join(',')
  else
    puts "Profiles already up-to-date (ie does not contain '#{COAB_DEBUG_PROFILE}' profile)"
  end

  coa_config.write_yaml_credentials(:profiles, active_profiles) if update_required
  update_required
end


config_path = ARGV[0]
puts config_path

feature_remove_coab_debug_profile(config_path)