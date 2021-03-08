module Upgrade
  class CfAppDeployment < Deployment
    ENABLE_CF_APP_DEPLOYMENT_FILENAME = 'enable-cf-app.yml'

    def initialize(name, root_deployment, config_base_dir)
      @name = name
      @root_deployment = root_deployment
      @config_base_dir = config_base_dir
    end

    def deployment_config_path
      File.join @config_base_dir, @root_deployment, 'cf-apps-deployments', @name
    end

    def enable_deployment_filename
      File.join(deployment_config_path,ENABLE_CF_APP_DEPLOYMENT_FILENAME)
    end

    def default_value(cf_org, cf_space)
      {
          "cf_api_url" => 'https://api.((' + 'cloudfoundry_system_domain' + '))',
          "cf_username" => "coa-cf",  # credential_leak_validated
          "cf_password" => "((" + "coa_cf_password" +"))",
          "cf_organization" => cf_org,
          "cf_space" => cf_space
      }
    end

    def create_enable_deployment(cf_org, cf_space)
      self.enable
      yaml_string = <<~YAML
        cf-app:
          #{@name}:
            cf_api_url: https://api.#{"((" + "cloudfoundry_system_domain" + "))"}
            cf_username: coa-cf  # credential_leak_validated
            cf_password: #{"((" + "coa_cf_password" +"))"}
            cf_organization: #{cf_org}
            cf_space: #{cf_space}
      YAML
      enable_cfapp_deployment = YAML.safe_load(yaml_string)
      update_local_file(enable_deployment_filename, enable_cfapp_deployment) if File.empty?(enable_deployment_filename)
    end

    def update_enable_deployment(enable_cfapp_deployment_content)
      update_local_file(enable_deployment_filename, enable_cfapp_deployment_content)
    end

    def load_enable_deployment
      load_local_file(enable_deployment_filename)
    end
  end
end
