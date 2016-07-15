lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(lib) if !$LOAD_PATH.include?(lib)

require 'redmine-installer'
require 'childprocess'

module STDHelper

  def _input
    RedmineInstaller.prompt.input
  end

  def _output
    RedmineInstaller.prompt.output
  end

end


RSpec.configure do |config|
  config.disable_monkey_patching!
  config.include STDHelper
end
