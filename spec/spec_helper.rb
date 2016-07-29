lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(lib) if !$LOAD_PATH.include?(lib)

require 'redmine-installer'

require 'custom_matchers'
require 'shared_contexts'

require 'installer_process'
require 'installer_helper'
require 'packages_helper'

RSpec.configure do |config|
  config.default_formatter = 'doc'
  config.color = true
  config.tty   = true

  config.disable_monkey_patching!

  config.include_context 'run installer', :command

  config.include PackagesHelper
  config.extend PackagesHelper
  config.include InstallerHelper

  config.after(:each) do
    log_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'log.log'))
    Kernel.system("cat #{log_file}")
  end
end
