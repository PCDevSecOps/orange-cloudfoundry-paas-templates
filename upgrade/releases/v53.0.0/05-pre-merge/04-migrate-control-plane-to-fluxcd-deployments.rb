#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'uri'
require_relative '../../../lib/upgrade'

def feature_clean(secrets_dir)
  deployments=%w(
     k8s-traefik-core-connectivity
     k8s-openldap
     k8s-jcr
     k8s-minio
  )
  micro_depls = Upgrade::RootDeployment.new('micro-depls',secrets_dir)
  micro_depls.disable_deployments(deployments)
end


config_path = ARGV[0]
puts config_path

feature_clean(config_path)