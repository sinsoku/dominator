require 'bundler'
require 'yaml'

require 'dominator/cli'
require 'dominator/console_formatter'
require 'dominator/csv_formatter'
require 'dominator/project'
require 'dominator/rubocop_config'
require 'dominator/version'

module Dominator
  class Error < StandardError; end
end
