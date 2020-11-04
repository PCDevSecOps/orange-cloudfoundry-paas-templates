#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'


def feature_cf_deployment(secrets_dir)
  puts "Processing #{__method__.to_s}"
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  apps_domain = shared_secrets_yaml.dig("secrets","cloudfoundry","apps_domain")
  unless apps_domain.nil?
    puts "Migrating apps_domain"
    shared_secrets_yaml["secrets"]["cloudfoundry"].delete("apps_domain")
    intranet_interco_1 = shared_secrets_yaml.dig("secrets", "intranet_interco_1") || {}
    intranet_interco_1.store("apps_domain", apps_domain)
    shared_secrets_yaml["secrets"]["intranet_interco_1"] = intranet_interco_1
    update_required = true
  else
    puts "apps_domain already migrated"
  end

  intranet_apps_domain = shared_secrets_yaml.dig("secrets", "intranet_interco_1","apps_domain")
  if intranet_apps_domain.nil?
    puts "WARNING: Intranet app domain is missing, it should be provided !!!"
    intranet_interco_1 = shared_secrets_yaml.dig("secrets", "intranet_interco_1") || {}
    intranet_interco_1.store("apps_domain", Upgrade::USER_VALUE_REQUIRED)
    shared_secrets_yaml["secrets"]["intranet_interco_1"] = intranet_interco_1
    update_required = true
  end

  iaas_dns = shared_secrets_yaml.dig("secrets", "bosh","iaas_dns")
  if iaas_dns.nil?
    puts "WARNING: iaas_dns is missing, it should be provided !!!"
    new_iaas_dns =  Array.new(2, Upgrade::USER_VALUE_REQUIRED)
    shared_secrets_yaml["secrets"]["bosh"]["iaas_dns"] = new_iaas_dns
    update_required = true
  end

  bosh = shared_secrets_yaml.dig("secrets", "bosh")
  if bosh
    puts "Migrating bosh.dns"
    shared_secrets_yaml["secrets"]["bosh"].delete("dns")
    update_required = true
  end


  dns_recursor = Upgrade::Deployment.new("dns-recursor",'micro-depls', secrets_dir)
  dns_recursor_secrets = dns_recursor.load_local_secrets
  dns1 = dns_recursor_secrets.dig('secrets','target_dns_recursor_1')
  dns2 = dns_recursor_secrets.dig('secrets','target_dns_recursor_2')
  ntp1 = dns_recursor_secrets.dig('secrets','target_ntp_server_1')
  ntp2 = dns_recursor_secrets.dig('secrets','target_ntp_server_2')
  dns_recursor_secrets.delete('secrets')
  dns_recursor.update_local_secrets(dns_recursor_secrets)

  unless dns1.nil?
    puts "Migrating dns and ntp"
    shared_secrets_yaml["secrets"]["cloudfoundry"].delete("apps_domain")
    intranet_interco_1 = shared_secrets_yaml.dig("secrets", "intranet_interco_1") || {}
    intranet_interco_1.store("intranet_dns_1", dns1)
    intranet_interco_1.store("intranet_dns_2", dns2)
    intranet_interco_1.store("ntp_server_1", ntp1)
    intranet_interco_1.store("ntp_server_2", ntp2)
    shared_secrets_yaml["secrets"]["intranet_interco_1"] = intranet_interco_1
    update_required = true
  else
    puts "dns and ntp already migrated"
  end

  intranet_2_dns = shared_secrets_yaml.dig("secrets", "intranet_interco_2","intranet_dns")
  unless intranet_2_dns.nil?
    puts "Migrating intranet_interco_2.intranet_dns_1"
    intranet_interco_2 = shared_secrets_yaml.dig("secrets", "intranet_interco_2") || {}
    intranet_interco_2.store("intranet_dns_1", intranet_2_dns)
    shared_secrets_yaml["secrets"]["intranet_interco_2"] = intranet_interco_2
    update_required = true
  end


  shared_secrets.write(shared_secrets_yaml) if update_required
end

def enable_isolation_segment_intranet_1(config_path)
  intranet_1 = Upgrade::Deployment.new("isolation-segment-intranet-1", "master-depls", config_path)
  intranet_1.enable
  secrets_yaml_string = <<~YAML
    meta:
      isolation_segment:
        gorouter_instances_count: 2
        diego_cell_instances_count: 2
  YAML
  new_meta = YAML.safe_load(secrets_yaml_string)
  intranet_1.create_local_meta(new_meta)
end

def update_sample_apps(config_path)
  sample_apps = Upgrade::CfAppDeployment.new('sample-apps', 'ops-depls', config_path)
  sample_apps.create_enable_deployment('system_domain', 'paas-templates-sample-apps')
end

config_path = ARGV[0]
puts config_path

feature_cf_deployment(config_path)
enable_isolation_segment_intranet_1(config_path)
update_sample_apps(config_path)