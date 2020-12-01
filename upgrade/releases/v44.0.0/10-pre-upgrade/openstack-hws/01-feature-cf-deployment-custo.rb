#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../../lib/upgrade'

def feature_cf_deployment(secrets_dir)
  puts "Processing #{__method__.to_s}"
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load
  update_required = false
  cf_org = shared_secrets_yaml.dig("secrets", "intranet_interco_1","cf_org")
  if cf_org.nil?
    puts "Migrating cf_org"
    internet_interco_1 = shared_secrets_yaml.dig("secrets", "intranet_interco_1") || {}
    internet_interco_1.store("cf_org", "orange")
    shared_secrets_yaml["secrets"]["intranet_interco_1"] = internet_interco_1
    update_required = true
  else
    puts "cf_org already migrated"
  end

  cf_org_internet = shared_secrets_yaml.dig("secrets", "internet_interco","cf_org")
  if cf_org_internet.nil?
    puts "Migrating cf_org_internet"
    internet_interco = shared_secrets_yaml.dig("secrets", "internet_interco") || {}
    internet_interco.store("cf_org", "orange-internet")
    shared_secrets_yaml["secrets"]["internet_interco"] = internet_interco
    update_required = true
  else
    puts "cf_org_internet already migrated"
  end

  apps_internet_domain = shared_secrets_yaml.dig("secrets","cloudfoundry","apps_internet_domain")
  apps_internet_domain_2 = shared_secrets_yaml.dig("secrets","cloudfoundry","apps_internet_domain_2")
  if !(apps_internet_domain.nil? && apps_internet_domain_2.nil?)
    puts "Migrating apps_internet_domain"
    shared_secrets_yaml["secrets"]["cloudfoundry"].delete("apps_internet_domain")
    shared_secrets_yaml["secrets"]["cloudfoundry"].delete("apps_internet_domain_2")
    internet_interco = shared_secrets_yaml.dig("secrets", "internet_interco") || {}
    internet_interco.store("apps_domain", apps_internet_domain) unless apps_internet_domain.nil?
    internet_interco.store("apps_domain_2", apps_internet_domain_2) unless apps_internet_domain_2.nil?
    shared_secrets_yaml["secrets"]["internet_interco"] = internet_interco
    update_required = true
  else
    puts "apps_internet_domain & apps_internet_domain already migrated"
  end

  shared_secrets.write(shared_secrets_yaml) if update_required
end


config_path = ARGV[0]
puts config_path

feature_cf_deployment(config_path)
