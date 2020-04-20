module Upgrade

  class CiDeployments

    def initialize(config_dir)
      @config_base_dir = config_dir
    end

    def list
      file_list = []
      search_pattern=@config_base_dir + '/**/' + Upgrade::CI_DEPLOYMENT_OVERVIEW_FILENAME
      Dir[search_pattern ].each do |deployment_file|
        file_list << deployment_file
      end
      puts "Cannot find any files matching <#{search_pattern}>" unless file_list
      file_list
    end

    def aggregate
      files = list
      raw_contents = files.map {|filename| YAML.load_file(filename)['ci-deployment']}
      merged = raw_contents.inject({}){ |all, item| all.merge(item)}
      merged
    end

    def teams
      aggregated_ci_overviews = aggregate
      pipelines = aggregated_ci_overviews.map { |_, value| value['pipelines'] }
      merged = pipelines.inject({}){ |all, item| all.merge(item)}

      teams = merged.map { | _, value| value['team']}.compact
      teams << 'main'  #we ensure 'main' team is always present
      teams.uniq
    end

    def self.team(overview, root_deployment, pipeline_name)
      ci_root_deployment = overview[root_deployment]
      ci_pipelines = ci_root_deployment['pipelines'] unless ci_root_deployment.nil?
      ci_pipeline_found = ci_pipelines[pipeline_name] unless ci_pipelines.nil?
      ci_pipeline_found['team'] unless ci_pipeline_found.nil?
    end
  end
end



