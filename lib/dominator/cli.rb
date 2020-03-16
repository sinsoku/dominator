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

      # formatter = ConsoleFormatter.new(projects)
      # formatter = CsvFormatter.new(projects)
      formatter = MarkdownFormatter.new(projects)
      puts formatter
    end
  end
end
