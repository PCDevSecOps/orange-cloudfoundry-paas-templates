#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'uri'
require_relative '../../../lib/upgrade'

def feature_credhub_seeding_for_concourse_teams(config_path)
  puts "Processing #{__method__.to_s}"

  coa_config = Upgrade::CoaConfig.new(config_path)
  loaded_git_config = coa_config.load_credentials(:git_config) || {}
  if loaded_git_config.empty?
    puts "ERROR: COA config file is missing: #{File.join(coa_config.location,coa_config.get(:git_config))}"
    exit 1
  end
  puts "Extracting info from #{coa_config.get(:git_config)}"
  git_config_secret_uri = loaded_git_config['secrets-uri']
  parsed_secret_uri = URI.parse(git_config_secret_uri)
  extracted_secrets_uri = "#{parsed_secret_uri.scheme}://#{parsed_secret_uri.host}#{parsed_secret_uri.path}"
  extracted_secrets_user="#{parsed_secret_uri.user}"
  extracted_secrets_password="#{parsed_secret_uri.password}"

  update_required = false
  shared_secrets = Upgrade::SharedSecrets.new(config_path)
  shared_secrets_content = shared_secrets.load
  # Expexted shared secrets format
  # ---
  #  ....
  # secrets:
  #   concourse:
  #     git:
  #       secrets:
  #         uri:
  #         user:
  #         password:

  secrets = shared_secrets_content['secrets']
  concourse = secrets.dig('concourse') || {}
  git = concourse.dig('git') || {}
  git_secrets = git.dig('secrets') || {}
  secrets_uri = git_secrets.dig('uri')

  if ! secrets_uri
    secrets_uri = extracted_secrets_uri
    update_required = true
  end

  secrets_user = git_secrets.dig('user')
  if ! secrets_user
    secrets_user = extracted_secrets_user
    update_required = true
  end

  secrets_password = git_secrets.dig('password')
  if ! secrets_password && ! extracted_secrets_password.start_with?('((')
    secrets_password = extracted_secrets_password
    update_required = true
  else
    puts "Skipping git secrets password update. Please manually check."
  end

  git_secrets['uri'] = secrets_uri
  git_secrets['user'] = secrets_user
  git_secrets['password'] = secrets_password
  git['secrets'] = git_secrets
  concourse['git'] = git
  secrets['concourse'] = concourse

  shared_secrets.write(shared_secrets_content) if update_required
end

config_path = ARGV[0]
puts config_path

feature_credhub_seeding_for_concourse_teams(config_path)