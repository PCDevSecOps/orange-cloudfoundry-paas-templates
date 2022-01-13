require 'optparse'
require 'kramdown'
require 'kramdown-parser-gfm'


class ManualStepExtractor
  def initialize(input_dir, output_dir)
    @input_dir = input_dir
    @output_dir = output_dir
  end

  def process(version, md_output = true, html_output = true)
    if version.to_s.empty?
      puts("FATAL: Version is missing.")
      exit(1)
    end
    formatted_version = version.tr('.','_')
    release_notes_filename = "V#{formatted_version}.md"
    manual_steps_output_filename="V#{formatted_version}-manual-steps-overview"
    manual_steps_output_md_filename="#{manual_steps_output_filename}.md"
    manual_steps_output_html_filename="#{manual_steps_output_filename}.html"
    release_notes_full_path_filename = File.join(@input_dir, release_notes_filename)
    unless File.exist?(release_notes_full_path_filename)
      puts("FATAL: Release note #{release_notes_filename} does not exist in #{@input_dir}")
      exit(1)
    end
    release_notes_markdown = File.read release_notes_full_path_filename

    parser = Kramdown::Document.new(release_notes_markdown, config)

    manual_platform_ops_doc = parser.dup
    manual_platform_ops_cleanup, manual_platform_ops_header, manual_platform_ops_post_upgrade, manual_platform_ops_pre_merge, manual_platform_ops_pre_upgrade = setup_sections
    fill_sections(manual_platform_ops_cleanup, manual_platform_ops_doc, manual_platform_ops_header, manual_platform_ops_post_upgrade, manual_platform_ops_pre_merge, manual_platform_ops_pre_upgrade)
    manual_platform_ops_doc_children =
      manual_platform_ops_header +
      manual_platform_ops_pre_merge +
      manual_platform_ops_pre_upgrade +
      manual_platform_ops_post_upgrade +
      manual_platform_ops_cleanup
    manual_platform_ops_doc.root.children = manual_platform_ops_doc_children
    File.open(File.join(@output_dir, manual_steps_output_md_filename), "w+") {|file| file.write(manual_platform_ops_doc.to_kramdown)} if md_output
    File.open(File.join(@output_dir, manual_steps_output_html_filename), "w+") {|file| file.write(manual_platform_ops_doc.to_html)} if html_output
    puts "Generated #{manual_steps_output_filename} - md: #{md_output} / html: #{html_output}"
  end

  private

  def fill_sections(manual_platform_ops_cleanup, manual_platform_ops_doc, manual_platform_ops_header, manual_platform_ops_post_upgrade, manual_platform_ops_pre_merge, manual_platform_ops_pre_upgrade)
    has_manual_platform_ops = false
    add_feature_name = false
    current_feature = nil
    current_step = nil
    filter_release_notes = false
    manual_platform_ops_doc.root.children.each do |item|
      #puts "Processing:" + item.options[:raw_text].to_s + " - children size: " + item.children.size.to_s + "level: " + item.options[:level].to_s
      if item.options[:raw_text].to_s.start_with?("Version detailed content") && item.options[:level] == 1 && item.type.to_s == "header"
        filter_release_notes = true
        # elsif item.options[:level] == 1 && item.type.to_s == "header"
        #   filter_release_notes = false
      elsif item.options[:raw_text].to_s.start_with?("feature-") && item.options[:level] == 2 && item.type.to_s == "header"
        puts "Feature found: #{item.inspect}"
        current_feature = item
        has_manual_platform_ops = false
        current_step = nil
      elsif item.options[:raw_text].to_s.start_with?("Manual platform ops") && item.options[:level] == 3 && item.type.to_s == "header"
        puts "Manual ops found: #{item.inspect}"
        has_manual_platform_ops = true
        add_feature_name = true
        current_step = nil
      elsif item.options[:raw_text].to_s.include?(" steps ") && item.options[:level] == 4 && item.type.to_s == "header"
        current_step = nil
        puts "Manual ops found: #{item.inspect}"
        add_feature_name = true
        has_manual_platform_ops = true
        if item.options[:raw_text].to_s.start_with?("Pre-merge")
          puts "Pre-merge manual ops found: #{item.inspect}"
          current_step = manual_platform_ops_pre_merge
          next
        elsif item.options[:raw_text].to_s.start_with?("Pre-upgrade")
          puts "Pre-upgrade manual ops found: #{item.inspect}"
          current_step = manual_platform_ops_pre_upgrade
          next
        elsif item.options[:raw_text].to_s.start_with?("Post-upgrade")
          puts "Post-upgrade manual ops found: #{item.inspect}"
          current_step = manual_platform_ops_post_upgrade
          next
        elsif item.options[:raw_text].to_s.start_with?("Clean-up")
          puts "Cleanup manual ops found: #{item.inspect}"
          current_step = manual_platform_ops_cleanup
          next
        else
          puts "UNDEFINED step !!!! found: #{item.inspect}"
        end
      end
      if !filter_release_notes
        manual_platform_ops_header << item
      elsif has_manual_platform_ops && current_step
        if add_feature_name
          puts "Add header for: #{current_feature.inspect}"
          current_step << current_feature #unless current_feature.nil?
          add_feature_name = false
        end
        puts "Add item : #{item.inspect}"
        current_step << item
      end
    end
  end

  def config
    {
      auto_ids: false,
      input: 'GFM',
      entity_output: :symbolic,
      # parse_block_html: true,
      # html_to_native: false,
      # enable_coderay: true,
      # syntax_highlighter: :coderay,
      # syntax_highlighter_opts: {  default_lang: 'shell', guess_lang: true},
      syntax_highlighter: :rouge,
    }
  end

  def setup_sections
    plan = Kramdown::Document.new("# Pre-Merge steps\n\n# Pre-Upgrade steps\n\n# Post-Upgrade\n\n# Cleanup\n", config)

    manual_platform_ops_header = []
    manual_platform_ops_pre_merge = [plan.root.children[0]]
    manual_platform_ops_pre_upgrade = [plan.root.children[2]]
    manual_platform_ops_post_upgrade = [plan.root.children[4]]
    manual_platform_ops_cleanup = [plan.root.children[6]]

    plan.root.children.each_with_index do |item, idx|
      puts "idx: #{idx}: #{item.inspect}"
    end
    return manual_platform_ops_cleanup, manual_platform_ops_header, manual_platform_ops_post_upgrade, manual_platform_ops_pre_merge, manual_platform_ops_pre_upgrade
  end
end

# Common command line parsing for upgrade scripts
class CommandLineParser
  OPTIONS = {
    input_dir: File.join(File.dirname(__FILE__), '..', 'zz-docs' ,'release-notes'),
    output_dir: File.join(File.dirname(__FILE__), '..', 'zz-docs' ,'release-notes'),
    md_output: true,
    html_output: true,
    version: ''
  }.freeze

  def initialize(options = OPTIONS.dup)
    @options = options
  end

  def parse
    options = @options
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Incomplete/wrong parameter(s): #{opts.default_argv}.\n Usage: ./#{opts.program_name} <options>"

      opts.on('-i', '--input PATH', "input directory when releases notes already exist. Default: #{options[:input_dir]}") do |ip_string|
        options[:input_dir] = ip_string
      end

      opts.on('-o', '--output PATH', "input directory when releases notes already exist. Default: #{options[:output_dir]}") do |op_string|
        options[:output_dir] = op_string
      end

      opts.on('-v', '--version VERSION', "Release notes version to use. Format <X.Y.Z> or 'latest'. ** MANDATORY ** - Default: #{options[:version]}") do |v_string|
        options[:version] = v_string
      end

      opts.on('--[no-]html', "generates html output. Default: #{options[:html_output]}") do |html|
        options[:html_output] = html
      end

      opts.on('--[no-]md', "generates md output. Default: #{options[:md_output]}") do |md|
        options[:md_output] = md
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end
    opt_parser.parse!
    @options = options
  end
end

options = CommandLineParser.new.parse

output_dir = options[:output_dir]
input_dir = options[:input_dir]
version = options[:version]
md_output  = options[:md_output]
html_output  = options[:html_output]

if version == 'latest'
  latest_version_path = Dir[File.join(input_dir,"V*_*_*.md")].sort.last
  version = File.basename(latest_version_path,'.md').delete_prefix('V').tr('_','.')
  puts "latest keyword detected, version detected: #{version}"
end
manual_step_extractor = ManualStepExtractor.new(input_dir, output_dir)
# %w[51.0.3 50.0.5 49.0.2 48.0.2].each {|version| manual_step_extractor.process(version, md_output, html_output)}
manual_step_extractor.process(version, md_output, html_output)

