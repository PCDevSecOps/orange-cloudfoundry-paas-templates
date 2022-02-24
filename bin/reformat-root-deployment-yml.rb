#!/bin/ruby
require 'yaml'

def reformat_root_deployment_yml(paas_template_root)
  root_deployments_path = Dir["#{paas_template_root}/*-depls/root-deployment.yml"]
  puts root_deployments_path

  root_deployments_path.each do |root_deployment_file|
    puts "Processing #{root_deployment_file}"
    root_deployment = YAML.load_file(root_deployment_file)
    new_root_deployment = root_deployment.dup
    releases = root_deployment['releases']
    releases.keys.each do |release_name|
      puts "\trelease_name: #{release_name}"
      details = releases[release_name]
      version = details['version']
      if version
        details['version'] = version.to_s
        new_root_deployment['releases'][release_name] = details
      else
        puts "/!\\ #{release_name} does not have version defined"
      end
    end

    File.open(root_deployment_file, 'w+') { |file| file.write(new_root_deployment.to_yaml) }
  end
end

paas_template_root = ARGV[0]
puts "Paas Templates path: #{paas_template_root}"

unless paas_template_root
  puts "Usage: #{File.basename(__FILE__)} <path_to_paas_template_root_directory>"
  exit 1
end
raise "invalid paas_template_root: <#{paas_template_root}> does not exist" unless Dir.exist?(paas_template_root)

reformat_root_deployment_yml(paas_template_root)

puts "Done"

puts
puts 'Thanks, Orange CloudFoundry SKC'

