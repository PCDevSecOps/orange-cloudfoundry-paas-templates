#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'uri'
require_relative '../../../lib/upgrade'

SECRETS = 'secrets'
NETWORKS = 'networks'
EXT_4 = 'tf-net-osb-data-plane-dedicated-priv-extension-4'
EXT_5 = 'tf-net-osb-data-plane-dedicated-priv-extension-5'

#    networks:
#       tf-net-osb-data-plane-dedicated-priv-extension-4: <first network name region-1>
#       tf-net-osb-data-plane-dedicated-priv-extension-5: <second network name region-1>

def feature_extend_dedicated_private_network(secrets_dir)
  update_required = false
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  networks = shared_secrets_yaml.dig(SECRETS, NETWORKS)
  if !networks
    puts "Init secrets slack notifications for region 1: [#{SECRETS}.#{NETWORKS}]"
    networks = {}
    shared_secrets_yaml[SECRETS][NETWORKS] = networks
  end

  ext4 = networks.dig(EXT_4)
  if !ext4
    puts "Please set secrets ext4 for region 1: [#{SECRETS}.#{NETWORKS}.#{EXT_4}]"
    shared_secrets_yaml[SECRETS][NETWORKS][EXT_4] = Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end

  ext5 = networks.dig(EXT_5)
  if !ext5
    puts "Please set secrets ext4 for region 1: [#{SECRETS}.#{NETWORKS}.#{EXT_5}]"
    shared_secrets_yaml[SECRETS][NETWORKS][EXT_5] = Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end

  shared_secrets.write(shared_secrets_yaml) if update_required
end


config_path = ARGV[0]
puts config_path

feature_extend_dedicated_private_network(config_path)