#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'
require_relative 'lib/upgrade'
require_relative 'lib/paas_templates_upgrader'

class CurrentCoaUpgrade < Upgrade::Coa


  def setup_profiles_properties
    active_profiles_file = File.join(@coa_config.location, @coa_config.get(:profiles))
    puts "> INFO: Checking #{active_profiles_file}"
    return 0 if File.exist?(active_profiles_file)
    puts "> INFO: generating new #{@coa_config.get(:profiles)}. Please check it content"
    content = <<~YAML
        # Mandatory. List active profiles (comma separated list without spaces)- Example: profile-1,profile-2 
        # Default: empty 
        profiles:
    YAML
    1 if @coa_config.write_raw_credentials(:profiles, content)
  end

  def cleanup_docker_registry_credentials_file
    docker_registry_filename = File.join(@coa_config.location, @coa_config.get(:docker_registry))
    puts "> INFO: Checking #{docker_registry_filename}"
    return 0 unless File.exist?(docker_registry_filename)
    puts "> INFO: Removing useless docker registry file"
    FileUtils.rm(docker_registry_filename)
  end

  def v4_3_upgrade
    setup_profiles_properties
    cleanup_docker_registry_credentials_file
  end

  def update_coa_config
    v4_3_upgrade
  end

  def apply_previous_upgrade
  end

  def setup_prerequisites
  end
end


options = PaasTemplatesUpgrader::CommandLineParser.new.parse
version = options[:version]
config_dir = options[:config_path]
step = options[:step]
iaas_type = options[:iaas_type]

version = ENV.fetch('COA_VERSION','') if version.empty?
raise "invalid version: <#{version}>. use -v <version> or set COA_VERSION=<version> - Format v<x.y.z>" if version.empty?

raise "invalid config_dir (#{config_dir})" unless Dir.exist?(config_dir)
coa_config = Upgrade::CoaConfig.new(config_dir)
coa = CurrentCoaUpgrade.new(coa_config, version)
coa.run
