##
# Validate redmine folder
#
module Redmine::Installer::Step
  class Validation < Base

    REDMINE_SHOULD_CONTAINT = [
      'app', 'lib', 'config', 'public', 'db',
      'Gemfile', 'Rakefile', 'config.ru',
      File.join('lib', 'redmine'),
      File.join('lib', 'redmine', 'core_ext'),
      File.join('lib', 'redmine', 'helpers'),
      File.join('lib', 'redmine', 'views'),
      File.join('lib', 'redmine.rb'),
    ].sort

    def up
      Dir.chdir(base.redmine_root) do
        @records = Dir.glob(File.join('**', '*')).sort
      end

      # Is this redmine
      unless (@records & REDMINE_SHOULD_CONTAINT) == REDMINE_SHOULD_CONTAINT
        error :error_redmine_not_contains_all, records: REDMINE_SHOULD_CONTAINT.join(', ')
      end

      # Plugins are in righ dir
      if @records.select{|x| x.start_with?('vendor/plugins')}.size > 1
        error :error_plugins_should_be_on_plugins
      end
    end

    def print_footer
      say '<green>... OK</green>', 1
    end

  end
end
