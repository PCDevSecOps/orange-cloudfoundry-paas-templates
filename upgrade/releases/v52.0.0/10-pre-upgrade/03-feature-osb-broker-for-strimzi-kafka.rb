#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

SECRETS = 'secrets'
MULTI_REGION = 'multi_region'
REGION_1 = 'region_1'
DNSAAS = 'dnsaas'
RFC2136_HOST = 'rfc2136_host'
RFC2136_ZONE_BACKEND_SERVICES = 'rfc2136_zone_backend_services'
RFC2136_TSIGKEYNAME='rfc2136_tsigKeyname'
RFC2136_TSIGSECRET='rfc2136_tsigSecret'

def init_dnsaas_config(secrets_dir)
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  dnsaas = shared_secrets_yaml.dig(SECRETS, MULTI_REGION, REGION_1, DNSAAS)
  if !dnsaas
    puts "Init secrets slack notifications for region 1: [#{SECRETS}.#{MULTI_REGION}.#{REGION_1}.#{DNSAAS}]"
    dnsaas = {}
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_1][DNSAAS] = dnsaas
  end

  update_required = false
  [RFC2136_HOST, RFC2136_ZONE_BACKEND_SERVICES, RFC2136_TSIGKEYNAME, RFC2136_TSIGSECRET].each do |key|
    rfc2136_key = dnsaas.dig(key)
    if !rfc2136_key
      puts "Please set secrets #{key} for region 1: [#{SECRETS}.#{MULTI_REGION}.#{REGION_1}.#{DNSAAS}.#{key}]"
      shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_1][DNSAAS][key] = Upgrade::USER_VALUE_REQUIRED
      update_required = true
    end
  end

  shared_secrets.write(shared_secrets_yaml) if update_required
end



def feature_osb_broker_for_strimzi_kafka(secrets_dir)
  puts "Processing #{__method__.to_s}"
  coab_secrets_yaml = <<~YAML
                secrets:
                  paas-templates-reference-branch: reference
                  cf-mysql-service-instances-branch: feature-coabdepls-cf-mysql-serviceinstances
                  cf-mysql-extended-service-instances-branch: feature-coabdepls-cf-mysql-extended-serviceinstances
                  noop-service-instances-branch: feature-coabdepls-noop-serviceinstances
                  cf-rabbit-service-instances-branch: feature-coabdepls-cf-rabbit-serviceinstances
                  cf-rabbit-extended-service-instances-branch: feature-coabdepls-cf-rabbit-extended-serviceinstances
                  mongodb-service-instances-branch: feature-coabdepls-mongodb-serviceinstances
                  mongodb-extended-service-instances-branch: feature-coabdepls-mongodb-extended-serviceinstances
                  redis-service-instances-branch: feature-coabdepls-redis-serviceinstances
                  redis-extended-service-instances-branch: feature-coabdepls-redis-extended-serviceinstances
                  strimzi-service-instances-branch: feature-coabdepls-strimzi-serviceinstances
  YAML
  coab_secrets_dir = File.join(secrets_dir, 'coab-depls', 'model-migration-pipeline', 'secrets')
  coab_secrets_filename = File.join(coab_secrets_dir, 'secrets.yml')

  if File.exist?(coab_secrets_filename)
    puts "WARNING: overriding #{coab_secrets_filename} because file already exists"
    File.open(coab_secrets_filename, 'w') { |file| file.write coab_secrets_yaml }
  else
    puts "creating #{coab_secrets_filename}"
    FileUtils.mkdir_p(coab_secrets_dir)
    File.open(coab_secrets_filename, 'w') { |file| file.write coab_secrets_yaml }
  end

  init_dnsaas_config(secrets_dir)
end

config_path = ARGV[0]
puts config_path

feature_osb_broker_for_strimzi_kafka(config_path)
