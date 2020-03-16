# frozen_string_literal: true

module Dominator
  class Project
    class << self
      def find_projects(*base_paths)
        projects = base_paths.flat_map do |base|
          Dir.glob('*/Gemfile', base: base).map do |gemfile_path|
            root = File.expand_path('..', "#{base}/#{gemfile_path}")
            new(root)
          end
        end
        projects.sort_by(&:name)
      end
    end

    def initialize(root)
      @root = root
    end
    attr_reader :root

    def name
      @name ||= "#{File.basename(File.dirname(root))}/#{File.basename(root)}"
    end

    def ruby_version
      safe_read('.ruby-version') || parser&.ruby_version.to_s
    end

    def bundler_version
      parser&.bundler_version.to_s
    end

    def specs
      parser ? parser.specs : []
    end

    def rubocop_config
      @rubocop_config ||= RubocopConfig.new(
        safe_read('.rubocop.yml'),
        safe_read('.rubocop_todo.yml')
      )
    end

    private

    def parser
      @lock_file ||= safe_read('Gemfile.lock')
        .then { |lockfile| Bundler::LockfileParser.new(lockfile) if lockfile }
    end

    def safe_read(filename)
      path = "#{root}/#{filename}"
      File.read(path) if File.exist?(path)
    end
  end
end
