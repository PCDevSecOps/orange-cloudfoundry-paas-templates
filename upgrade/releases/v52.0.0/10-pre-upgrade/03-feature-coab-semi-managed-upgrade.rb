#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'uri'
require_relative '../../../lib/upgrade'

# Expected secrets format:

def default_values
  yaml = <<~YAML
    coab-managed-upgrade:
      trigger:
        description: "We extract some parameters from https://github.com/concourse/time-resource#source-configuration, to ease configuration."
        scan-frequency: 5m
        scan-frequency-description: "scan-frequency: interval between each trigger of this job - See `interval`, format: 90s, 5m, or 1 hour"
        start: "20:00"
        start-description: "Time when we start to trigger - See `start`, format: 8:00 PM, or 20:00"
        stop: "08:00"
        stop-description: "Time when we stop to trigger - See `stop`, format: 8:00 AM, or 08:00"
      jobs:
        max-running-description: "Number of coab dedicated instances processed in parallel in the upgrade-coab-remaining-instances job"
        max-running: 10
        max-errors-description: "When this value is reached, we stop scheduling of new jobs"
        max-errors: 10
  YAML
  YAML.safe_load(yaml)
end

def feature_coab_semi_managed_upgrade(config_path)
  puts "Processing #{__method__.to_s}"

  coa_config = Upgrade::CoaConfig.new(config_path)
  coab_managed_upgrade_config = coa_config.load_credentials(:coab_managed_upgrade) || default_values

  # coab_managed_upgrade_config_updated = default_values

  coab_managed_upgrade = coab_managed_upgrade_config['coab-managed-upgrade'] || default_values['coab-managed-upgrade']
  puts "coab_managed_upgrade:"
  puts coab_managed_upgrade
  puts "---------------------"
  trigger = default_values['coab-managed-upgrade']['trigger'].merge(coab_managed_upgrade&.dig('trigger') || {})
  jobs = default_values['coab-managed-upgrade']['jobs'].merge(coab_managed_upgrade&.dig('jobs') || {})

  coab_managed_upgrade_config.store('coab-managed-upgrade', coab_managed_upgrade)
  coab_managed_upgrade_config['coab-managed-upgrade'].store('trigger', trigger)
  coab_managed_upgrade_config['coab-managed-upgrade'].store('jobs', jobs)

  puts coab_managed_upgrade_config
  coa_config.write_yaml_credentials(:coab_managed_upgrade, coab_managed_upgrade_config)

end

config_path = ARGV[0]
puts config_path

feature_coab_semi_managed_upgrade(config_path)