#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def feature_director_ssl_fqdn(config_dir)
  puts "Processing #{__method__.to_s}"
  creds_filepath = File.join(config_dir, 'bootstrap', 'micro-bosh', 'creds.yml')
  creds = if File.exist?(creds_filepath)
            YAML.load_file(creds_filepath) || {}
          else
            {}
          end
  raise "Invalid creds.yml: empty. Please check #{creds_filepath}" if creds.empty?

  creds.delete_if {|key, _value| key == "director_ssl" }
  File.open(creds_filepath, 'w') { |file| file.write YAML.dump(creds) }
end

config_path = ARGV[0]
puts config_path

feature_director_ssl_fqdn(config_path)



