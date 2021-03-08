module Upgrade

  class CiDeploymentOverviewPipelineActivation
    def initialize(root_deployment_name, pipelines = {})
      @root_deployment_name = root_deployment_name
      @pipelines = pipelines || {}
    end

    def activate
      current_yaml = <<~YAML
        #{@root_deployment_name}-update-generated: {}
      YAML
      x = YAML.safe_load(current_yaml)
      @pipelines.merge!(x)
    end

    def pipelines
      @pipelines
    end

    def activate_bosh_pipelines
      bosh_pipelines_yaml = <<~YAML
        #{@root_deployment_name}-bosh-generated:
          team: #{@root_deployment_name}
      YAML
      bosh_pipelines = YAML.safe_load(bosh_pipelines_yaml)
      @pipelines.merge!(bosh_pipelines)
    end

    def activate_concourse_pipelines(team = @root_deployment_name)
      @pipelines["#{@root_deployment_name}-concourse-generated"] = {'team' => team }
    end

    def activate_cf_apps_pipelines(team = @root_deployment_name)
      # @pipelines["#{@root_deployment_name}-cf-apps-generated"] = {'team' => @root_deployment_name }
      @pipelines["#{@root_deployment_name}-cf-apps-generated"] = {'team' => team }
    end

    def activate_news_pipelines(team = 'utils')
      @pipelines["#{@root_deployment_name}-news-generated"] = {'team' => team }
    end

    def activate_pipeline(type, team = 'main')
      pipeline_team = if team.empty? || team == 'main'
                        {}
                      else
                        { 'team' => @root_deployment_name }
                      end
      @pipelines["#{@root_deployment_name}-#{type}-generated"] = pipeline_team
    end
  end

  CI_DEPLOYMENT_OVERVIEW_FILENAME = 'ci-deployment-overview.yml'
  class CiDeploymentOverview
    CI_DEPLOYMENT_OVERVIEW_FILENAME = 'ci-deployment-overview.yml'
    CREDENTIALS_AUTO_INIT_FILENAME = 'credentials-auto-init.yml'

    def self.filename(root_deployment_name, config_dir)
      File.join(config_dir,root_deployment_name, CI_DEPLOYMENT_OVERVIEW_FILENAME)
    end

    def initialize(root_deployment_name, config_dir)
      @config_base_dir = config_dir
      @root_deployment_name = root_deployment_name
      @location = File.join(config_dir,root_deployment_name, CI_DEPLOYMENT_OVERVIEW_FILENAME)
      @auto_init_path = File.join(config_dir,'coa','config', CREDENTIALS_AUTO_INIT_FILENAME)
    end

    def add_default_auto_init_credentials
      update_auto_init("concourse-5-for-#{@root_deployment_name}", ConcourseEnv.url, ConcourseEnv.username, ConcourseEnv.password, ConcourseEnv.insecure)
    end

    def update_auto_init(name, target, username, password, insecure)
      auto_init = load_file(@auto_init_path)
      auto_init["concourse-#{@root_deployment_name}"] = name unless auto_init["concourse-#{@root_deployment_name}"]
      auto_init["concourse-#{@root_deployment_name}-target"] = target unless auto_init["concourse-#{@root_deployment_name}-target"]
      auto_init["concourse-#{@root_deployment_name}-username"] = username  unless auto_init["concourse-#{@root_deployment_name}-username"] # credential_leak_validated
      auto_init["concourse-#{@root_deployment_name}-password"] = password unless auto_init["concourse-#{@root_deployment_name}-password"]
      auto_init["concourse-#{@root_deployment_name}-insecure"] = insecure unless auto_init["concourse-#{@root_deployment_name}-insecure"]
      update(@auto_init_path, auto_init)
    end

    def ci_deployment_overview_filename
      @location
    end

    def load
      @loaded_file_content = load_file(@location)
      @loaded_file_content
    end

    def update(file_path = @location,content = @loaded_file_content)
      unless File.exist?(file_path)
        puts "creating #{file_path}"
        basedir = File.dirname(file_path)
        FileUtils.mkdir_p(basedir)
      end
      File.open(file_path, 'w') { |file| file.write YAML.dump(content) }
    end

    def target_name(name = "concourse-5-for-#{@root_deployment_name}")
      ci_deployment = @loaded_file_content.dig('ci-deployment') || {}
      root_deployment = ci_deployment.dig(@root_deployment_name) || {}
      root_deployment['target_name'] = name
      ci_deployment[@root_deployment_name] = root_deployment
      @loaded_file_content['ci-deployment'] = ci_deployment
      @loaded_file_content
    end

    def enable_terraform(state_file_path = "#{@root_deployment_name}/terraform-config")
      ci_deployment = @loaded_file_content.dig('ci-deployment') || {}
      root_deployment = ci_deployment.dig(@root_deployment_name) || {}
      terraform_config = root_deployment.dig('terraform_config') || {}
      terraform_config['state_file_path'] = state_file_path
      root_deployment['terraform_config'] = terraform_config
      ci_deployment[@root_deployment_name] = root_deployment
      update(File.join(@config_base_dir,state_file_path, '.gitkeep'),'{}')
      @loaded_file_content['ci-deployment'] = ci_deployment
      @loaded_file_content
    end

    def update_pipeline(new_pipelines_values)
      ci_deployment = @loaded_file_content.dig('ci-deployment') || {}
      root_deployment = ci_deployment.dig(@root_deployment_name) || {}
      pipelines = root_deployment.dig('pipelines') || {}
      root_deployment['pipelines'] = pipelines.merge new_pipelines_values
      ci_deployment[@root_deployment_name] = root_deployment
      @loaded_file_content['ci-deployment'] = ci_deployment
      @loaded_file_content
    end

    private

    def load_file(file_path)
      puts "WARNING: #{file_path} does not exist" unless File.exist?(file_path)
      if File.exist?(file_path)
        YAML.load_file(file_path)
      else
        {}
      end
    end
  end
end
