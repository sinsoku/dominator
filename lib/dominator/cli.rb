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

      projects.each do |project|
        puts "## #{project.name}"
        puts "ruby: #{project.ruby_version}"
        puts "bundler: #{project.bundler_version}"
        puts "rubocop: #{project.rubocop_version}"
        puts
        puts "## Cops size: #{project.rubocop_config.cops.size}"
        project.rubocop_config.cops.each do |cop|
          puts cop
        end
        puts
      end
    end
  end
end
