#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'

SECRETS_DIR = ARGV[0]
COA_CONFIG_DIR = File.join(SECRETS_DIR,"coa", "config")
AUTO_INIT_FILENAME = "credentials-auto-init.yml"
S3_BR_FILENAME = "credentials-s3-br.yml"
S3_STEMCELL_FILENAME = "credentials-s3-stemcell.yml"
UNDEFINED = ''
COA_VERSION_FILENAME = "credentials-git-config.yml"

def get_concourse_info
  concourse_url = ENV.fetch('CONCOURSE_URL', UNDEFINED)
  raise "Missing CONCOURSE_URL" if concourse_url.empty?

  concourse_username = ENV.fetch('CONCOURSE_USERNAME', UNDEFINED) # credential_leak_validated
  raise "Missing CONCOURSE_USERNAME" if concourse_username.empty?

  concourse_password = ENV.fetch('CONCOURSE_PASSWORD', UNDEFINED)
  raise "Missing CONCOURSE_PASSWORD" if concourse_password.empty?

  [concourse_url, concourse_username, concourse_password]
end

def bump_coa_version(coa_config)
  expected_coa_version = ENV.fetch("COA_VERSION",false)
  raise "FATAL: COA_VERSION is missing" unless expected_coa_version
  coa_version_file = File.join(coa_config, COA_VERSION_FILENAME)
  coa_info = YAML.load_file(coa_version_file)
  current_coa_version = coa_info['cf-ops-automation-tag-filter']
  if current_coa_version == expected_coa_version
    puts "COA already configured to use <#{expected_coa_version}>"
  else
    puts "upgrading COA from <#{current_coa_version}> to <#{expected_coa_version}>"
    coa_info['cf-ops-automation-tag-filter'] = expected_coa_version
    File.open(coa_version_file, 'w') { |file| file.write YAML.dump(coa_info) }
  end
end

def update_auto_init(coa_config)
  puts "upgrading #{AUTO_INIT_FILENAME}"
  auto_init_filename = File.join(coa_config, AUTO_INIT_FILENAME)
  auto_init = YAML.load_file(auto_init_filename)

  concourse_info = get_concourse_info
  new_auto_init = {}
  auto_init.each do |key, value|
    case key
    when /concourse-.+-depls-target/
      new_auto_init[key] = concourse_info[0]
    when /concourse-.+-depls-username/
      new_auto_init[key] = concourse_info[1]
    when /concourse-.+-depls-password/
      new_auto_init[key] = concourse_info[2]
    when /concourse-(.+-depls)$/
      new_auto_init[key] = "concourse-5-for-#{$1}"
    else
      puts "ignoring <#{key}> with  <#{value}>"
      new_auto_init[key] = value
    end
  end
  new_auto_init['concourse-ldap-admin-groups'] = 'admin'
  new_auto_init['concourse-cf-admin-groups'] = 'system-domain'
  File.open(auto_init_filename, 'w') { |file| file.write YAML.dump(new_auto_init) }
end

def update_s3_credentials(coa_config)
  puts "upgrading #{S3_BR_FILENAME}"
  s3_br_filename = File.join(coa_config, S3_BR_FILENAME)
  s3_br = YAML.load_file(s3_br_filename)
  s3_br['s3-br-secret-key'] = '((' + 'private-s3-secret-key' + '))'
  File.open(s3_br_filename, 'w') { |file| file.write YAML.dump(s3_br) }

  puts "upgrading #{S3_STEMCELL_FILENAME}"
  s3_stemcell_filename = File.join(coa_config, S3_STEMCELL_FILENAME)
  s3_stemcell = YAML.load_file(s3_stemcell_filename)
  s3_stemcell['s3-stemcell-secret-key'] = '((' + 'private-s3-secret-key' + '))'
  File.open(s3_stemcell_filename, 'w') { |file| file.write YAML.dump(s3_stemcell) }
end

def setup_concourse_5_teams(secrets_dir)
  puts "upgrading teams"
  Dir[ File.join(secrets_dir, '**', 'ci-deployment-overview.yml')].each do |ci_deployment_overview_filename|
    puts "processing #{ci_deployment_overview_filename}"
    ci_deployment_overview = YAML.load_file(ci_deployment_overview_filename)
    root_deployment_name = ci_deployment_overview['ci-deployment'].keys.first
    next if root_deployment_name == 'expe-depls'

    root_deployment_level = ci_deployment_overview['ci-deployment'][root_deployment_name]
    root_deployment_level['target_name'] = "concourse-5-for-#{root_deployment_name}"
    pipelines_level = root_deployment_level['pipelines']
    pipelines_level&.filter { |_, pipeline_details| pipeline_details.nil? }
        &.map { |pipeline_name, pipeline_details| pipelines_level[pipeline_name] = {} }
    pipelines_level&.each do |pipeline_name, pipeline_details|
      case pipeline_name
      when /#{root_deployment_name}-bosh-generated/, /#{root_deployment_name}-cf-apps-generated/, /#{root_deployment_name}-concourse-generated/
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
    root_deployment_level['pipelines'] = pipelines_level
    File.open(ci_deployment_overview_filename, 'w') { |file| file.write YAML.dump ci_deployment_overview }
  end
end

def cleanup_micro_depls_ci_deployment_overview(secrets_dir)
  ci_deployment_overview_filename = File.join(secrets_dir, 'micro-depls', 'ci-deployment-overview.yml')
  puts "cleaning #{ci_deployment_overview_filename}"
  ci_deployment_overview = YAML.load_file(ci_deployment_overview_filename)
  root_deployment_name = 'micro-depls'
  root_deployment_level = ci_deployment_overview['ci-deployment'][root_deployment_name]
  root_deployment_level['pipelines'].delete_if { |pipeline_name, _| pipeline_name == 'control-plane' }
  File.open(ci_deployment_overview_filename, 'w') { |file| file.write YAML.dump ci_deployment_overview }
end

def reset_coa_generated_pipeline_dir
  dir_to_reset = File.join(SECRETS_DIR,'coa', 'pipelines', 'generated')
  if File.exist?(dir_to_reset)
    puts "resetting #{dir_to_reset}"
    FileUtils.rm_rf(dir_to_reset)
    FileUtils.mkdir_p(dir_to_reset)
    git_keep = File.join(dir_to_reset, '.gitkeep')
    FileUtils.touch git_keep
  else
    puts "skipping #{dir_to_reset} reset (dir does not exist)"
  end
end

def feature_delete_concourse_credhub_seeder(secrets_dir)
  puts "Processing #{__method__.to_s}"
  credhub_concourse_seeder_filename = File.join(secrets_dir, 'micro-depls', 'credhub-concourse-seeder', 'enable-deployment.yml')
  puts "cleaning #{credhub_concourse_seeder_filename}"
  FileUtils.rm(credhub_concourse_seeder_filename) if File.exist?(credhub_concourse_seeder_filename)
end

def feature_rabbitmq_operators(secrets_dir)
  puts "Processing #{__method__.to_s}"
  rabbit_yaml = <<~YAML
                meta:
                  rabbitmq-broker:
                    rabbitmq:
                      operator_set_policy:
                        policy_name: "operator_set_policy"
                        policy_definition: "{\\"ha-mode\\":\\"exactly\\",\\"ha-params\\":2,\\"ha-sync-mode\\":\\"automatic\\",\\"max-length\\":700000}"
                        policy_priority: 200

  YAML
  rabbit_secrets_dir = File.join(secrets_dir, 'ops-depls', 'cf-rabbit', 'secrets')
  rabbit_meta_filename = File.join(rabbit_secrets_dir, 'meta.yml')

  if File.exist?(rabbit_meta_filename)
    puts "WARNING: skipping #{rabbit_meta_filename}, file already exists"
  else
    puts "creating #{rabbit_meta_filename}"
    FileUtils.mkdir_p(rabbit_secrets_dir)
    File.open(rabbit_meta_filename, 'w') { |file| file.write rabbit_yaml }
  end
end

def feature_dns_hardening_phase_3(secrets_dir)
  puts "Processing #{__method__.to_s}"
  micro_depls_terraform_secrets_dir = File.join(secrets_dir, 'micro-depls', 'terraform-config', 'secrets')
  terraform_meta_filename = File.join(micro_depls_terraform_secrets_dir, 'meta.yml')

  if File.exist?(terraform_meta_filename)
    puts "cleaning #{terraform_meta_filename}"
    terraform_meta = YAML.load_file(terraform_meta_filename)
    meta_level = terraform_meta['meta']
    meta_level.delete_if { |key, _| key == 'powerdns_server_ip' || key == 'powerdns_record' }


    File.open(terraform_meta_filename, 'w') { |file| file.write YAML.dump terraform_meta }
  else
    puts "WARNING: skipping #{terraform_meta_filename}, file already exists"
  end

  powerdns_dir = File.join(secrets_dir, 'micro-depls', 'powerdns-docker')
  if File.exist?(powerdns_dir)
    puts "Deleting  #{powerdns_dir}"
    FileUtils.rm_rf(powerdns_dir)
  else
    puts "Skipping #{powerdns_dir} already deleted"
  end
end

def feature_fix_cf_overlapping_domains_impacts(secrets_dir)
  puts "Processing #{__method__.to_s}"
  shared_secrets_dir = File.join(secrets_dir, 'shared')
  shared_secrets_filename = File.join(shared_secrets_dir, 'secrets.yml')

  if File.exist?(shared_secrets_filename)
    puts "cleaning #{shared_secrets_filename}"
    shared_secrets = YAML.load_file(shared_secrets_filename)
    secrets_level = shared_secrets['secrets']
    secrets_level.delete_if { |key, _| key == 'apps_http_domain' }
    File.open(shared_secrets_filename, 'w') { |file| file.write YAML.dump shared_secrets }
  else
    puts "WARNING: skipping #{shared_secrets_filename}, file already exists"
  end
end

def feature_fix_admin_ui_cfapp(secrets_dir)
  puts "Processing #{__method__.to_s}"
  shared_secrets_dir = File.join(secrets_dir, 'shared')
  shared_secrets_filename = File.join(shared_secrets_dir, 'secrets.yml')

  if File.exist?(shared_secrets_filename)
    puts "cleaning #{shared_secrets_filename}"
    shared_secrets = YAML.load_file(shared_secrets_filename)
    secrets_level = shared_secrets['secrets']
    cf_level = secrets_level['cloudfoundry']
    cf_level.delete_if { |key, _| key == 'ccdb_host' }
    File.open(shared_secrets_filename, 'w') { |file| file.write YAML.dump shared_secrets }
  else
    puts "WARNING: skipping #{shared_secrets_filename}, file already exists"
  end
end

def feature_bosh_cli_v42(secrets_dir)
  puts "Processing #{__method__.to_s}"
  docker_bosh_cli_version="2.1.36"
  docker_bosh_cli_secrets_dir = File.join(secrets_dir, 'micro-depls', 'docker-bosh-cli', 'secrets')
  docker_bosh_cli_secrets_filename = File.join(docker_bosh_cli_secrets_dir, 'secrets.yml')

  if File.exist?(docker_bosh_cli_secrets_filename)
    puts "updating #{docker_bosh_cli_secrets_filename} with new version #{docker_bosh_cli_version}"
    docker_bosh_cli_secrets = YAML.load_file(docker_bosh_cli_secrets_filename)
    properties_level = docker_bosh_cli_secrets['properties']
    containers_level = properties_level&.fetch('containers')
    containers_level&.each do |datacontainer|
      image = datacontainer['image']
      image_parsed = image.split(':')
      image_name = image_parsed[0]
      image_version = image_parsed[1]
      datacontainer['image']= "#{image_name}:#{docker_bosh_cli_version}"
    end
    puts "updating datacontainers volumes"
    new_mount_point = '/var/vcap/data/tmp/bosh-cli:/var/tmp/bosh-cli:ro'
    datacontainer = containers_level.filter { |container| container['name'] == 'datacontainer'}.first
    datacontainer_index = containers_level.index(datacontainer)
    datacontainer['volumes'] << new_mount_point unless datacontainer['volumes'].include?(new_mount_point)
    containers_level[datacontainer_index] = datacontainer

    File.open(docker_bosh_cli_secrets_filename, 'w') { |file| file.write YAML.dump(docker_bosh_cli_secrets) }
  else
    puts "FATAL: #{docker_bosh_cli_secrets_filename} does not exist"
    exit 1
  end
end

def feature_logsearch(secrets_dir)
  puts "Processing #{__method__.to_s}"
  default_meta_yaml = <<~YAML
                meta:
                  logsearch:
                    elasticsearch_master_instances_count: 3
                    elasticsearch_data_instances_count: 3
                    ingestor_instances_count: 4
                    elasticsearch_data_instances_vm_type: large
                    elasticsearch_master_instances_vm_type: large
                    ingestor_instances_vm_type: large
                  elasticsearch_data:
                    health:
                      timeout: 3600
  YAML
  default_meta_root_level = YAML.safe_load(default_meta_yaml)

  logsearch_ops_secrets_dir = File.join(secrets_dir, 'master-depls', 'logsearch-ops', 'secrets')
  logsearch_ops_meta_filename = File.join(logsearch_ops_secrets_dir, 'meta.yml')

  if File.exist?(logsearch_ops_meta_filename)
    puts "updating #{logsearch_ops_meta_filename}"
    root_level = YAML.load_file(logsearch_ops_meta_filename)
    root_level['meta']['logsearch'] = default_meta_root_level['meta']['logsearch'] unless root_level['meta']['logsearch']
    root_level['meta']['logsearch']['ingestor_instances_count'] = root_level['meta']['logsearch-ops']&.fetch('ingestor_instances_count', nil) if root_level['meta']['logsearch-ops']&.fetch('ingestor_instances_count', nil)
    root_level['meta']['logsearch']['elasticsearch_master_instances_count'] = root_level['meta']['logsearch-ops']&.fetch('ingestor_instances_count', nil) if root_level['meta']['logsearch-ops']&.fetch('ingestor_instances_count', nil)
    root_level['meta']['logsearch']['elasticsearch_data_instances_count'] = root_level['meta']['logsearch-ops']&.fetch('elasticsearch_data_instances_count', nil) if root_level['meta']['logsearch-ops']&.fetch('elasticsearch_data_instances_count', nil)
    root_level['meta'].delete_if { |key| key == 'logsearch-ops'}
    File.open(logsearch_ops_meta_filename, 'w') { |file| file.write YAML.dump(root_level) }
  else
    puts "creating #{logsearch_ops_meta_filename}"
    FileUtils.mkdir_p(logsearch_ops_secrets_dir)
    File.open(logsearch_ops_meta_filename, 'w') { |file| file.write default_meta_root_level }
  end


end

def setup_prerequisites
  puts "=> Setup pre-requisite"
end

def post_update
  puts "=> Post update"
  reset_coa_generated_pipeline_dir
end

def update_secrets
  puts "=> Update Secrets"
  setup_concourse_5_teams(SECRETS_DIR)
  cleanup_micro_depls_ci_deployment_overview(SECRETS_DIR)
  feature_delete_concourse_credhub_seeder(SECRETS_DIR)
  feature_rabbitmq_operators(SECRETS_DIR)
  feature_dns_hardening_phase_3(SECRETS_DIR)
  feature_fix_cf_overlapping_domains_impacts(SECRETS_DIR)
  feature_fix_admin_ui_cfapp(SECRETS_DIR)
  feature_bosh_cli_v42(SECRETS_DIR)
  feature_logsearch(SECRETS_DIR)
end

def update_coa_config
  puts "=> Update COA Config"
  bump_coa_version(COA_CONFIG_DIR)
  update_auto_init(COA_CONFIG_DIR)
  update_s3_credentials(COA_CONFIG_DIR)
end

setup_prerequisites
update_coa_config
update_secrets
post_update
