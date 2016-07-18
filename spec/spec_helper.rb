lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(lib) if !$LOAD_PATH.include?(lib)

require 'redmine-installer'
require 'redmine_installer_process'
require 'custom_matcher'

RSpec.configure do |config|
  config.default_formatter = 'doc'
  config.color = true
  config.tty   = true

  config.disable_monkey_patching!
end
