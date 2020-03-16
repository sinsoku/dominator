# frozen_string_literal: true

module Dominator
  class ConsoleFormatter
    def initialize(projects)
      @projects = projects
    end

    def to_s
      buf = []

      spec_names = Project.spec_names(projects)
      cop_names = Project.cop_names(projects)

      buf << '## Projects'
      projects.each do |project|
        buf << "- #{project.name}"
      end
      buf << ''

      projects.each do |project|
        buf << "## #{project.name}"
        buf << "ruby: #{project.ruby_version}"
        buf << "bundler: #{project.bundler_version}"
        buf << ''
        spec_names.each do |spec_name|
          spec = project.specs.find { |spec| spec.name == spec_name }
          buf << "#{spec_name}: #{spec&.version.to_s}"
        end
        buf << ''
        cop_names.each do |cop_name|
          cop = project.rubocop_config.cops[cop_name]
          buf << "#{cop_name}: #{cop}"
        end
        buf << ''
      end
      buf.join("\n")
    end

    private

    attr_reader :projects
  end
end
