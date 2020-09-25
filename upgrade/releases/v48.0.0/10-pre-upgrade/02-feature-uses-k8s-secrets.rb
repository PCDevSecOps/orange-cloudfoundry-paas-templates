#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

def feature_k8s_operators(secrets_dir,deploy)
  puts "Processing #{__method__.to_s}"
  k8s_yaml = <<~YAML
                meta:
                  k8s:
                    # Nodes characteristics
                    nb_node: 3
                    # Nodes dedicated to persistent characteristics
                    nb_node_persistent: 4
                    # Nodes dedicated to exposition characteristics
                    nb_node_public: 2
                    # ETCD characteristics
                    nb_etcd: 3
  YAML
  k8s_secrets_dir = File.join(secrets_dir, deploy, 'k8s', 'secrets')
  k8s_meta_filename = File.join(k8s_secrets_dir, 'meta.yml')

  if File.exist?(k8s_meta_filename)
    puts "WARNING: skipping #{k8s_meta_filename}, file already exists"
  else
    puts "creating #{k8s_meta_filename}"
    FileUtils.mkdir_p(k8s_secrets_dir)
    File.open(k8s_meta_filename, 'w') { |file| file.write k8s_yaml }
  end
end


config_path = ARGV[0]
puts config_path

feature_k8s_operators(config_path,'micro-depls')
feature_k8s_operators(config_path,'master-depls')
feature_k8s_operators(config_path,'coab-depls')