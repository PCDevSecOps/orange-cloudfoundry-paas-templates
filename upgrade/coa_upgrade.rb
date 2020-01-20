#!/usr/bin/env ruby

require 'yaml'
require_relative 'lib/upgrade'
require_relative 'lib/paas_templates_upgrader'

class CurrentCoaUpgrade < Upgrade::Coa


  def setup_credhub_properties
    return 0 if @coa_config.load_credentials(:credhub)
    puts "> INFO: generating new #{@coa_config.get(:credhub)}. Please check it content"
    content = <<~YAML
        # Mandatory. Credhub server url to use. By default, we use credhub provided by paas-templates 
        credhub-server: https://credhub.internal.paas:8844
        # Mandatory. Credhub machine client to use. 
        credhub-client: director_to_credhub
        # Madatory. 
        credhub-secret: ((/secrets/bosh_credhub_secrets))
    YAML
    1 if @coa_config.write_raw_credentials(:credhub, content)
  end

  def init_credhub_docker_registry_key(docker_registry_url)
    add_key_into_concourse_credhub_namespace("/docker-registry-url", docker_registry_url)
  end

  def disable_docker_registry_credentials_definition
    shared_secrets = Upgrade::SharedSecrets.load(@coa_config.config_base_dir)
    ops_domain = shared_secrets.dig('secrets', 'ops_interco', 'ops_domain') || ''
    raise "Ops domain not defined, please check shared/secrets.yml" if ops_domain.empty?

    loaded_docker_registry = @coa_config.load_credentials(:docker_registry)

    if loaded_docker_registry && ! loaded_docker_registry.empty?
      init_credhub_docker_registry_key(loaded_docker_registry['docker-registry-url'])
      puts "> INFO: generating new #{@coa_config.get(:docker_registry)}. Please check it content"
      content = <<~YAML
          # WARNING - This property is now defined in credhub, please adjust it in `shared/secrets.yml`.
          # The path is `secrets.coa.config.docker-registry-url`
          # Set docker registry url to use a private one, (use 'registry.hub.docker.com/' to use docker hub) - Format <host>:<port>/ 
          # Default paas template value: `docker-registry-url: "elpaaso.#{ops_domain}/"`
      YAML
      1 if @coa_config.write_raw_credentials(:docker_registry, content)
    end
  end

  def add_docker_registry_to_shared_secrets
    update_required = false
    shared_secrets = Upgrade::SharedSecrets.new(@coa_config.config_base_dir)
    shared_secrets_level = shared_secrets.load
    ops_domain = shared_secrets_level.dig('secrets', 'ops_interco', 'ops_domain') || ''
    raise "Ops domain not defined, please check shared/secrets.yml" if ops_domain.empty?

    coa_level = shared_secrets_level.dig('secrets','coa') || {}
    shared_secrets_level['secrets']['coa'] = coa_level
    config_level = coa_level.dig('config') || {}
    coa_level['config'] = config_level
    docker_registry_level = config_level.dig('docker-registry-url') || ''
    if docker_registry_level.empty?
      puts "updating docker-registry-url in shared/secrets.yml"
      config_level['docker-registry-url'] = "elpaaso-nexus.#{ops_domain}/"
      update_required = true
    else
      puts "skipping, docker-registry-url already defined in shared/secrets.yml "
    end

    shared_secrets.write(shared_secrets_level) if update_required
  end

  def v4_2_upgrade
    setup_credhub_properties
    add_docker_registry_to_shared_secrets
    disable_docker_registry_credentials_definition
  end

  def update_coa_config
    v4_2_upgrade
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

coa_config = Upgrade::CoaConfig.new(config_dir)
coa = CurrentCoaUpgrade.new(coa_config, version)
coa.run
