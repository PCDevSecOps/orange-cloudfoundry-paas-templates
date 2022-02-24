#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'uri'
require_relative '../../../lib/upgrade'

SECRETS = 'secrets'
NETWORKS = 'networks'
EXT_4 = 'tf-net-osb-data-plane-dedicated-priv-extension-4'
EXT_5 = 'tf-net-osb-data-plane-dedicated-priv-extension-5'

MULTI_REGION = 'multi_region'
REGION_2 = 'region_2'
PUB_2 = 'tf-net-osb-data-plane-shared-pub2'
PRIV = 'tf-net-osb-data-plane-shared-priv'
DATA_PLANE_SHARED_PUBLIC_2 = 'data_plane_shared_public2'
NET_ID = 'net_id'
RANGE = 'range'
GATEWAY = 'gateway'
RESERVED_DHCP = 'reserved_dhcp'
RESERVED_VRRP = 'reserved_vrrp'
STATIC = 'static'

#    networks:
#       tf-net-osb-data-plane-dedicated-priv-extension-4: <first network name region-1>
#       tf-net-osb-data-plane-dedicated-priv-extension-5: <second network name region-1>

# secrets:
#    multi_region:
#      region_2:
#        tf-net-osb-data-plane-shared-pub2: <public network name>
#        tf-net-osb-data-plane-shared-priv: <private network name>
#...
#        data_plane_shared_public2:
#         net_id: <net_id>
#         range: <range>
#         gateway: <gateway>
#         reserved_dhcp: <reserved for dhcp>
#         reserved_vrrp: <reserved for vrrp>
#         static: <reserved for static>
#...






def feature_new_mariadb_shared(secrets_dir)
  update_required = false
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  region_2 = shared_secrets_yaml.dig(SECRETS, MULTI_REGION, REGION_2)
  if !region_2
    puts "Init secrets slack notifications for multi_region/region_2: [#{SECRETS}.#{MULTI_REGION}.#{REGION_2}]"
    region_2 = {}
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_2] = region_2
  end

  pub_2 = region_2.dig(PUB_2)
  if !pub_2
    puts "Please set secrets pub_2 for multi_region/region_2: [#{SECRETS}.#{MULTI_REGION}.#{REGION_2}.#{PUB_2}]"
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_2][PUB_2] = Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end

  priv = region_2.dig(PRIV)
  if !priv
    puts "Please set secrets priv for multi_region/region_2: [#{SECRETS}.#{MULTI_REGION}.#{REGION_2}.#{PRIV}]"
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_2][PRIV] = Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end



  data_plane_shared_public_2 = shared_secrets_yaml.dig(SECRETS, MULTI_REGION, REGION_2, DATA_PLANE_SHARED_PUBLIC_2)
  if !data_plane_shared_public_2
    puts "Init secrets slack notifications for multi_region/region_2/data_plane_shared_public_2: [#{SECRETS}.#{MULTI_REGION}.#{REGION_2}.#{DATA_PLANE_SHARED_PUBLIC_2}]"
    data_plane_shared_public_2 = {}
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_2][DATA_PLANE_SHARED_PUBLIC_2] = data_plane_shared_public_2
  end

  net_id = data_plane_shared_public_2.dig(NET_ID)
  if !net_id
    puts "Please set secrets net_id for multi_region/region_2/data_plane_shared_public_2: [#{SECRETS}.#{MULTI_REGION}.#{REGION_2}.#{DATA_PLANE_SHARED_PUBLIC_2}]"
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_2][DATA_PLANE_SHARED_PUBLIC_2][NET_ID] = Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end

  range = data_plane_shared_public_2.dig(RANGE)
  if !range
    puts "Please set secrets range for multi_region/region_2/data_plane_shared_public_2: [#{SECRETS}.#{MULTI_REGION}.#{REGION_2}.#{DATA_PLANE_SHARED_PUBLIC_2}]"
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_2][DATA_PLANE_SHARED_PUBLIC_2][RANGE] = Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end

  gateway = data_plane_shared_public_2.dig(GATEWAY)
  if !gateway
    puts "Please set secrets gateway for multi_region/region_2/data_plane_shared_public_2: [#{SECRETS}.#{MULTI_REGION}.#{REGION_2}.#{DATA_PLANE_SHARED_PUBLIC_2}]"
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_2][DATA_PLANE_SHARED_PUBLIC_2][GATEWAY] = Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end

  reserved_dhcp = data_plane_shared_public_2.dig(RESERVED_DHCP)
  if !reserved_dhcp
    puts "Please set secrets reserved_dhcp for multi_region/region_2/data_plane_shared_public_2: [#{SECRETS}.#{MULTI_REGION}.#{REGION_2}.#{DATA_PLANE_SHARED_PUBLIC_2}]"
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_2][DATA_PLANE_SHARED_PUBLIC_2][RESERVED_DHCP] = Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end

  reserved_vrrp = data_plane_shared_public_2.dig(RESERVED_VRRP)
  if !reserved_vrrp
    puts "Please set secrets reserved_vrrp for multi_region/region_2/data_plane_shared_public_2: [#{SECRETS}.#{MULTI_REGION}.#{REGION_2}.#{DATA_PLANE_SHARED_PUBLIC_2}]"
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_2][DATA_PLANE_SHARED_PUBLIC_2][RESERVED_VRRP] = Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end

  static = data_plane_shared_public_2.dig(STATIC)
  if !static
    puts "Please set secrets static for multi_region/region_2/data_plane_shared_public_2: [#{SECRETS}.#{MULTI_REGION}.#{REGION_2}.#{DATA_PLANE_SHARED_PUBLIC_2}]"
    shared_secrets_yaml[SECRETS][MULTI_REGION][REGION_2][DATA_PLANE_SHARED_PUBLIC_2][STATIC] = Upgrade::USER_VALUE_REQUIRED
    update_required = true
  end

  shared_secrets.write(shared_secrets_yaml) if update_required
end

config_path = ARGV[0]
puts config_path

feature_new_mariadb_shared(config_path)