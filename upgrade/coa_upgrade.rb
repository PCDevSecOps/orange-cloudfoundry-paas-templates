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

  def disable_precompilation_for_upgrade
    update_required = false
    private_config = Upgrade::PrivateConfig.new(@coa_config.config_base_dir)
    private_config_content = private_config.load
    if private_config_content.has_key?('precompile-mode')
      puts "> INFO: Precompile mode already set: #{private_config_content['precompile-mode']}"
    else
      puts "> INFO: Disabling COA 5 precompile-mode"
      private_config_content['precompile-mode'] = false
      update_required = true
    end
    private_config.write(private_config_content) if update_required
  end

  def setup_precompile_credentials_file
    compiled_releases_filename = File.join(@coa_config.location, @coa_config.get(:s3_compiled_releases))

    puts "> INFO: Updating #{compiled_releases_filename}"

    s3_compiled_releases_credentials = @coa_config.load_credentials(:s3_compiled_releases)  || {}

    s3_compiled_releases_credentials['s3-compiled-release-bucket'] = 'compiled-releases' unless s3_compiled_releases_credentials.has_key?('s3-compiled-release-bucket')
    s3_compiled_releases_credentials['s3-compiled-release-region-name'] = 'us-east-1' unless s3_compiled_releases_credentials.has_key?('s3-compiled-release-region-name')
    s3_compiled_releases_credentials['s3-compiled-release-access-key-id'] = 'private-s3' unless s3_compiled_releases_credentials.has_key?('s3-compiled-release-access-key-id')
    s3_compiled_releases_credentials['s3-compiled-release-secret-key'] =  "((private-s3-secret-key))" unless s3_compiled_releases_credentials.has_key?('s3-compiled-release-secret-key')
    s3_compiled_releases_credentials['s3-compiled-release-endpoint'] = "http://private-s3.internal.paas:9000/" unless s3_compiled_releases_credentials.has_key?('s3-compiled-release-endpoint')
    s3_compiled_releases_credentials['s3-compiled-release-skip-ssl-verification'] =  true unless s3_compiled_releases_credentials.has_key?('s3-compiled-release-skip-ssl-verification')
    s3_compiled_releases_credentials['s3-compiled-release-os'] = "ubuntu-xenial" unless s3_compiled_releases_credentials.has_key?('s3-compiled-release-os')

    puts "> INFO: Writing #{compiled_releases_filename}"
    @coa_config.write_yaml_credentials(:s3_compiled_releases, s3_compiled_releases_credentials)
  end

  def v5_0_upgrade
    disable_precompilation_for_upgrade
    setup_precompile_credentials_file
  end

  def update_coa_config
    v5_0_upgrade
  end

  def apply_previous_upgrade
    v4_3_upgrade
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
