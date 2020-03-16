# frozen_string_literal: true

module Dominator
  CONFIG_PATH = '.dominator.yml'

  class CLI
    def self.invoke(args = ARGV)
      if args.empty?
        puts 'USAGE: dominator <path>'
        exit 1
      end

      projects = Project.find_projects(*args)
      if File.exist?(CONFIG_PATH)
        config = YAML.load_file(CONFIG_PATH)
        projects.select! { |project| config['Include'].include?(project.name) }
      end

      puts '## Projects'
      projects.each do |project|
        puts "- #{project.name}"
      end
      puts

      spec_names = projects.flat_map { |project| project.specs.map(&:name) }
        .uniq.sort
      cop_names = projects.flat_map { |project| project.rubocop_config.cops.keys }
        .uniq.sort

      projects.each do |project|
        puts "## #{project.name}"
        puts "ruby: #{project.ruby_version}"
        puts "bundler: #{project.bundler_version}"
        puts
        spec_names.each do |spec_name|
          spec = project.specs.find { |spec| spec.name == spec_name }
          puts "#{spec_name}: #{spec&.version.to_s}"
        end
        puts
        cop_names.each do |cop_name|
          cop = project.rubocop_config.cops[cop_name]
          puts "#{cop_name}: #{cop}"
        end
        puts
      end
    end
  end
end
