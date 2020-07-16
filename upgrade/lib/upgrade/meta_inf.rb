module Upgrade
  class MetaInf
    def self.load
        paas_templates_dir = File.realpath(File.join(File.dirname(__FILE__), '..', '..', '..'))
        meta_inf_filename = File.join(paas_templates_dir, 'meta-inf.yml')
        raise "FATAL: #{meta_inf_filename} does not exist" unless File.exist?(meta_inf_filename)

        YAML.load_file(meta_inf_filename)
    end
  end
end
