# frozen_string_literal: true

require 'csv'

module Dominator
  class CsvFormatter
    def initialize(projects)
      @projects = projects
    end

    def to_s
      spec_names = Project.spec_names(projects)
      cop_names = Project.cop_names(projects)

      headers = ['project', 'ruby', 'bundler', *spec_names, *cop_names]
      CSV.generate do |csv|
        csv << headers
        projects.each do |project|
          spec_versions = spec_names.map do |spec_name|
            spec = project.specs.find { |spec| spec.name == spec_name }
            spec&.version.to_s
          end
          cop_values = cop_names.map do |cop_name|
            cop = project.rubocop_config.cops[cop_name]
            cop['Enabled'] || cop['Max'] if cop
          end

          row = [
            project.name,
            project.ruby_version,
            project.bundler_version,
            *spec_versions,
            *cop_values
          ]
          csv << row
        end
      end
    end

    private

    attr_reader :projects
  end
end
