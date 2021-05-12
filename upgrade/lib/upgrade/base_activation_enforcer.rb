module Upgrade
  class BaseActivationEnforcer
    def initialize(config_path)
      @config_path = config_path
    end

    def micro_depls
      Upgrade::RootDeployment.new('micro-depls',@config_path)
    end

    def master_depls
      Upgrade::RootDeployment.new('master-depls',@config_path)
    end

    def ops_depls
      Upgrade::RootDeployment.new('ops-depls',@config_path)
    end

    def coab_depls
      Upgrade::RootDeployment.new('coab-depls',@config_path)
    end

    def kubo_depls
      Upgrade::RootDeployment.new('kubo-depls',@config_path)
    end


    def enable_micro_depls; end
    def disable_micro_depls; end
    def micro_depls_pipelines; end
    def micro_depls_ci_overview; end

    def enable_master_depls; end
    def disable_master_depls; end
    def master_depls_pipelines; end
    def master_depls_ci_overview; end

    def enable_ops_depls; end
    def disable_ops_depls; end
    def ops_depls_pipelines; end
    def ops_depls_cf_apps; end
    def ops_depls_ci_overview; end

    def enable_coab_depls; end
    def disable_coab_depls; end
    def coab_depls_pipelines; end
    def coab_depls_cf_apps; end
    def coab_depls_ci_overview; end

    def enable_kubo_depls; end
    def disable_kubo_depls; end
    def kubo_depls_pipelines; end
    def kubo_depls_ci_overview; end

    def other_root_deployment_operations; end

    def run
      enable_micro_depls
      disable_micro_depls
      micro_depls_pipelines
      micro_depls_ci_overview

      enable_master_depls
      disable_master_depls
      master_depls_pipelines
      master_depls_ci_overview

      enable_ops_depls
      disable_ops_depls
      ops_depls_pipelines
      ops_depls_cf_apps
      ops_depls_ci_overview

      enable_coab_depls
      disable_coab_depls
      coab_depls_pipelines
      coab_depls_cf_apps
      coab_depls_ci_overview

      enable_kubo_depls
      disable_kubo_depls
      kubo_depls_pipelines
      kubo_depls_ci_overview

      other_root_deployment_operations
    end
  end
end
