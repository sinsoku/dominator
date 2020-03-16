# frozen_string_literal: true

module Dominator
  class MarkdownFormatter
    def initialize(projects)
      @projects = projects
    end

    def to_s
      buf = []
      buf << "## Basic"
      buf << basic_block
      buf << "## Gems"
      buf << gems_block
      buf << "## Cops"
      Project.departments(projects).each do |department|
        buf << "### #{department}"
        buf << cops_block(department)
      end

      buf.join("\n\n")
    end

    private

    attr_reader :projects

    def basic_block
      buf = []
      buf << ['project', *projects.map(&:name)]
      buf << ['ruby', *projects.map(&:ruby_version)]
      buf << ['bundler', *projects.map(&:bundler_version)]
      buf << ['rails', *projects.map(&:rails_version)]
      buf << ['rubocop', *projects.map(&:rubocop_version)]
      rubocop_gems = projects.map { |project| project.rubocop_config.requires.join('<br>') }
      buf << ['rubocop gems', *rubocop_gems]

      md_table(buf)
    end

    def gems_block
      buf = []
      buf << ['project', *projects.map(&:name)]

      spec_names = Project.spec_names(projects)
      spec_names.each do |spec_name|
        versions = projects.map do |project|
          spec = project.specs.find { |spec| spec.name == spec_name }
          spec.version.to_s if spec
        end
        buf << [spec_name, *mark_min(versions)]
      end

      md_table(buf)
    end

    def cops_block(department)
      buf = []
      buf << ['project', *projects.map(&:name)]
      disabled_size = projects.map do |project|
        cops = project.rubocop_config.cops(department)
        cops.select { |k, v| v['Enabled'] == false }.size
      end
      buf << ['disabled size', *disabled_size]

      cop_names = Project.cop_names(projects)
        .select { |cop_name| cop_name.include?(department) }
      cop_names.each do |cop_name|
        cop_values = projects.map do |project|
          cop = project.rubocop_config.cops[cop_name]
          format_cop_value(cop) if cop
        end
        buf << [cop_name.delete("#{department}/"), *cop_values]
      end

      md_table(buf)
    end

    def md_table(array)
      header = md_row(array[0])
      separator = md_row(Array.new(array[0].size, '---'))
      rows = array[1..].map { |row| md_row(row) }

      [header, separator, *rows].join("\n")
    end

    def mark_min(rows)
      return rows if rows.compact.uniq.size < 2

      min = rows.compact.sort_by { |version| Gem::Version.new(version) }.first
      rows.map { |v| v == min ? ":gem: **#{v}**" : v }
    end


    def md_row(array)
      "| #{array.join(' | ')} |"
    end

    def format_cop_value(hash)
      hash.map { |k, v| ['Include', 'Exclude'].include?(k) ? "#{k}: ..." : "#{k}: #{v}" }
        .join('<br>')
    end
  end
end
