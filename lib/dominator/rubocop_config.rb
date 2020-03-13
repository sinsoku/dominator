# frozen_string_literal: true

module Dominator
  class RubocopConfig
    def initialize(str, todo_str)
      @str = str
      @todo_str = todo_str
    end

    def cops
      merged_yaml.select { |k, _v| k.include?('/') }
    end

    private

    attr_reader :str, :todo_str

    def merged_yaml
      return @merged_yaml if defined?(@merged_yaml)

      yaml = str ? YAML.load(str) : {}
      todo_yaml = todo_str ? YAML.load(todo_str) : {}

      @merged_yaml = todo_yaml.merge(yaml)
    end
  end
end
