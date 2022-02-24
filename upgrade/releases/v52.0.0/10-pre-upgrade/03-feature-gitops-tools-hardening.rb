#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'uri'
require_relative '../../../lib/upgrade'

SECRETS = 'secrets'
MULTI_REGION = 'multi_region'
REGION_1 = 'region_1'
SLACK_NOTIF = 'slack-notifications'
WEBHOOK = 'webhook'
CHANNEL = 'channel'

CONCOURSE = 'concourse'
GIT = 'git'
TEMPLATE = 'template'
TEMPLATE_URI = 'uri'
USER = 'user'
PASSWORD = 'password'
WIP_MERGED_BRANCH='wip-merged-branch'


def update_slack_config(secrets_dir)
  update_required = false
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  slack_notifications = shared_secrets_yaml.dig(SECRETS, MULTI_REGION, REGION_1, SLACK_NOTIF)
  if !slack_notifications
    puts "Init secrets slack notifications for region 1: [#{SECRETS}.#{MULTI_REGION}.#{REGION_1}.#{SLACK_NOTIF}]"
    slack_notifications = {}
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_1][SLACK_NOTIF] = slack_notifications
  end

  slack_webhook = slack_notifications.dig(WEBHOOK)
  if !slack_webhook
    puts "Please set secrets slack_webhook for region 1: [#{SECRETS}.#{MULTI_REGION}.#{REGION_1}.#{SLACK_NOTIF}.#{WEBHOOK}]"
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_1][SLACK_NOTIF][WEBHOOK] = Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end

  slack_channel = slack_notifications.dig(CHANNEL)
  if !slack_channel
    puts "Please set slack channel for region 1: [#{SECRETS}.#{MULTI_REGION}.#{REGION_1}.#{SLACK_NOTIF}.#{CHANNEL}]"
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_1][SLACK_NOTIF][CHANNEL] = Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end

  shared_secrets.write(shared_secrets_yaml) if update_required
end

def update_paas_template_git_config(secrets_dir)
  update_required = false
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  template = shared_secrets_yaml.dig(SECRETS, CONCOURSE, GIT, TEMPLATE) || {}
  shared_secrets_yaml[SECRETS][CONCOURSE][GIT][TEMPLATE] = template

  coa_config = Upgrade::CoaConfig.new(secrets_dir)
  git_config_yaml = coa_config.load_credentials(:git_config)

  git_config_template_uri = git_config_yaml.dig('paas-templates-uri') || ''
  parsed_template_uri = URI.parse(git_config_template_uri)
  ops_domain=shared_secrets_yaml.dig(SECRETS,'ops_interco','ops_domain') || Upgrade::USER_VALUE_REQUIRED
  extracted_template_uri = "#{parsed_template_uri.scheme}://#{parsed_template_uri.host}#{parsed_template_uri.path}".gsub!("((cloudfoundry_ops_domain))",ops_domain)
  extracted_template_user="#{parsed_template_uri.user}"
  concourse_git_secrets_password=shared_secrets_yaml.dig(SECRETS,CONCOURSE,GIT,'secrets','password')|| Upgrade::USER_VALUE_REQUIRED
  extracted_template_password="#{parsed_template_uri.password}".gsub("((concourse_git_secrets_password))",concourse_git_secrets_password)


  uri = template.dig(TEMPLATE_URI)
  if !uri
    puts "Set [#{SECRETS}.#{CONCOURSE}.#{GIT}.#{TEMPLATE}.#{TEMPLATE_URI}]"
    template[TEMPLATE_URI] = extracted_template_uri
    update_required = true
  end

  user = template.dig(USER)
  if !user
    puts "Set [#{SECRETS}.#{CONCOURSE}.#{GIT}.#{TEMPLATE}.#{USER}]"
    template[USER] = extracted_template_user
    update_required = true
  end

  password = template.dig(PASSWORD)
  if !password
    puts "Set [#{SECRETS}.#{CONCOURSE}.#{GIT}.#{TEMPLATE}.#{PASSWORD}]"
    template[PASSWORD] = extracted_template_password
    update_required = true
  end


  wip_merged_branch = template.dig(WIP_MERGED_BRANCH)
  if !wip_merged_branch
    puts "Set [#{SECRETS}.#{CONCOURSE}.#{GIT}.#{TEMPLATE}.#{WIP_MERGED_BRANCH}]"
    template[WIP_MERGED_BRANCH] = git_config_yaml['paas-templates-branch'] || Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end


  shared_secrets.write(shared_secrets_yaml) if update_required
end



def feature_gitops_tools_hardening(secrets_dir)
  puts "Processing #{__method__.to_s}"

  update_slack_config(secrets_dir)
  update_paas_template_git_config(secrets_dir)
end

config_path = ARGV[0]
puts config_path

feature_gitops_tools_hardening(config_path)
