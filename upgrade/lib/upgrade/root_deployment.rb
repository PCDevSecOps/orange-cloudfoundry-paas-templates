module Upgrade
  class RootDeployment < LocalFile
    def enable_deployments(deployments = [])
      deployments.each do |deployment_name|
        puts "Enabling #{deployment_name}"
        current_deployment = Upgrade::Deployment.new(deployment_name, @name, @config_base_dir)
        current_deployment.enable
      end
    end

    def disable_deployments(deployments = [])
      deployments.each do |deployment_name|
        puts "Disabling #{deployment_name}"
        current_deployment = Upgrade::Deployment.new(deployment_name, @name, @config_base_dir)
        current_deployment.disable
      end
    end

    def destroy_deployments(deployments = [])
      deployments.each do |deployment_name|
        puts "Deleting #{deployment_name}"
        current_deployment = Upgrade::Deployment.new(deployment_name, @name, @config_base_dir)
        current_deployment.destroy
      end
    end

    def enable_cf_app_deployments(cf_app_deployments = [])
      default_cf_org = 'system_domain'
      cf_app_deployments.each do |cf_app_deployment_name|
        puts "Enabling cf app #{cf_app_deployment_name}"
        cf_app_deployment = Upgrade::CfAppDeployment.new(cf_app_deployment_name, @name, @config_base_dir)
        cf_app_deployment.create_enable_deployment(default_cf_org, cf_app_deployment_name)
      end
    end

    def disable_cf_app_deployments(cf_app_deployments = [])
      cf_app_deployments.each do |cf_app_deployment_name|
        puts "Disabling cf app #{cf_app_deployment_name}"
        cf_app_deployment = Upgrade::CfAppDeployment.new(cf_app_deployment_name, @name, @config_base_dir)
        cf_app_deployment.disable
      end
    end

    def destroy_cf_app_deployments(cf_app_deployments = [])
      cf_app_deployments.each do |cf_app_deployment_name|
        puts "Deleting cf app #{cf_app_deployment_name}"
        cf_app_deployment = Upgrade::CfAppDeployment.new(cf_app_deployment_name, @name, @config_base_dir)
        cf_app_deployment.destroy
      end
    end

    def destroy_deployment_objects(deployment_objects = [])
      deployment_objects.each do |deployment|
        puts "Deleting #{deployment}"
        deployment.destroy
      end
    end

    def enable_deployment_objects(deployment_objects = [])
      deployment_objects.each do |deployment|
        puts "Enabling #{deployment}"
        deployment.enable
      end
    end

    def disable_deployment_objects(deployment_objects = [])
      deployment_objects.each do |deployment|
        puts "Disabling #{deployment}"
        deployment.disable
      end
    end
  end
end
