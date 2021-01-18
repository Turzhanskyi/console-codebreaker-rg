# frozen_string_literal: true

require 'bundler/setup'
require 'table_print'
require 'codebreaker'
require 'i18n'
require 'pry'

require_relative '../lib/services/output'
require_relative '../lib/services/input'
require_relative '../lib/services/game_process'
require_relative '../lib/console'

I18n.load_path << Dir["#{File.expand_path('config/locales')}/*.yml"]
