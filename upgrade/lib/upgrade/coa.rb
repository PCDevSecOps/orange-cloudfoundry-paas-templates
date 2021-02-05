module Upgrade

  class Coa
    attr_reader :coa_config, :version

    def initialize(coa_config, version)
      @coa_config = coa_config
      @version = version
    end

    def bump_coa_version
      expected_coa_version = @version
      raise "FATAL: COA_VERSION is missing" unless expected_coa_version

      coa_info = @coa_config.load_credentials(:git_config)
      current_coa_version = coa_info['cf-ops-automation-tag-filter']
      if current_coa_version == expected_coa_version
        puts "COA already configured to use <#{expected_coa_version}>"
      else
        puts "upgrading COA from <#{current_coa_version}> to <#{expected_coa_version}>"
        coa_info['cf-ops-automation-tag-filter'] = expected_coa_version
        @coa_config.write_yaml_credentials(:git_config, coa_info)
      end
    end

    def add_key_into_concourse_credhub_namespace(key_suffix, value)
      overviews=Upgrade::CiDeployments.new(@coa_config.config_base_dir)
      teams=overviews.teams
      teams.each do |team|
        key_name = "/concourse-micro/#{team}#{key_suffix}"
        Upgrade::CredhubCli::set_value(key_name, value)
      end
    end

    def update_coa_config
    end

    def apply_previous_upgrade
    end

    def setup_prerequisites
    end

    def run
      apply_previous_upgrade
      setup_prerequisites
      bump_coa_version
      update_coa_config
    end

  end
end
