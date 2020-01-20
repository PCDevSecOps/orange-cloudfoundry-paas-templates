#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

#
# Harbor is now inside K8S-master
#

def destroy_harbor_deployment(config_path)
  intranet_1 = Upgrade::Deployment.new("harbor", "master-depls", config_path)
  intranet_1.destroy
end



config_path = ARGV[0]
puts config_path

destroy_harbor_deployment(config_path)
