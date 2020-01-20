#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

def setup_concourse_5_teams(secrets_dir)
  puts "upgrading teams"
  Dir[ File.join(secrets_dir, '**', 'ci-deployment-overview.yml')].each do |ci_deployment_overview_filename|
    puts "processing #{ci_deployment_overview_filename}"
    ci_deployment_overview = YAML.load_file(ci_deployment_overview_filename)
    root_deployment_name = ci_deployment_overview['ci-deployment'].keys.first
    next if root_deployment_name == 'expe-depls'

    root_deployment_level = ci_deployment_overview['ci-deployment'][root_deployment_name]
    root_deployment_level['target_name'] = "concourse-5-for-#{root_deployment_name}"
    root_deployment_level['pipelines'].each do |pipeline_name, pipeline_details|
      case pipeline_name
      when /#{root_deployment_name}-tf-generated/, /#{root_deployment_name}-bosh-generated/, /#{root_deployment_name}-cf-apps-generated/, /#{root_deployment_name}-concourse-generated/
        puts "moving #{pipeline_name} to #{root_deployment_name} team"
        pipeline_details['team'] = root_deployment_name
      when /#{root_deployment_name}-news-generated/, /#{root_deployment_name}-sync-helper-generated/
        puts "moving #{pipeline_name} to utils team"
        pipeline_details['team'] = 'utils'
      when /#{root_deployment_name}-s3-br-upload-generated/, /#{root_deployment_name}-s3-stemcell-upload-generated/
        puts "moving #{pipeline_name} to upload team"
        pipeline_details['team'] = 'upload'
      else
        puts "ignoring #{pipeline_name}"
      end
    end
    File.open(ci_deployment_overview_filename, 'w') { |file| file.write YAML.dump ci_deployment_overview }
  end
end

def cleanup_tf_pipelines_from_main_team(config_path)
  coa_generated_pipelines_dir = File.join(config_path, 'coa', 'pipelines', 'generated', 'main')
  puts "cleaning tf pipelines from main team"
  Dir[ File.join(coa_generated_pipelines_dir, '**', '*tf-generated.yml')].each do |tf_pipeline_filename|
    puts "removing #{tf_pipeline_filename}"
    FileUtils.rm(tf_pipeline_filename)
  end
end

config_path = ARGV[0]

setup_concourse_5_teams(config_path)
cleanup_tf_pipelines_from_main_team(config_path)