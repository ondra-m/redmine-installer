# require 'simplecov'
# SimpleCov.start

require 'tmpdir'
require 'tempfile'
require 'fileutils'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'redmine-installer'
require 'load_redmine'

RSpec.configure do |config|
  config.default_formatter = 'doc'
  config.color = true
  config.tty   = true

  config.add_setting :mysql
  config.mysql = {
    host: 'localhost',
    port: '3306',
    username: 'root',
    password: 'root'
  }

  config.after(:suite) do
    LoadRedmine.clean
  end
end
