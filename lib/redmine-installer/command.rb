module Redmine::Installer
  class Command
    RAKE_DB_CREATE = 'bundle exec rake db:create RAILS_ENV=production'
    RAKE_DB_MIGRATE = 'bundle exec rake db:migrate RAILS_ENV=production'
    RAKE_GENERATE_SECRET_TOKEN = 'bundle exec rake generate_secret_token RAILS_ENV=production'
    RAKE_REDMINE_PLUGIN_MIGRATE = 'bundle exec rake redmine:plugins:migrate RAILS_ENV=production'
    BUNDLE_INSTALL = 'bundle install --without development test'

    def self.git_clone(repository, target=nil)
      "git clone #{repository} #{target}"
    end
  end
end

##
# Class for easier create complex command
#
# == Examples:
#
# Instead of this:
#   exec('rake redmine:plugins:migrate RAILS_ENV=production')
#
# you can write:
#   rake.plugin_migrate.production.run
#
# module Redmine::Installer
#   module Command
#     class Base
#       # Register main command only for child class
#       def self.command(cmd)
#         self.class_variable_set('@@command', cmd)
#       end

#       # Register new argument and method name
#       def self.add(name, cmd)
#         self.class_eval <<-EVAL
#           def #{name}
#             arguments << '#{cmd}'
#             self
#           end
#         EVAL
#       end

#       def initialize(command=nil)
#         @command = self.class.class_variable_get('@@command')
#       end

#       def arguments
#         @arguments ||= []
#       end

#       def command
#         %{#{@command} #{arguments.join(' ')}}
#       end

#       def run(title=nil, with_timer=false)
#         Redmine::Installer::Exec.new(command, title, with_timer).run
#       end

#       def repeatable_run(title=nil, with_timer=false)
#         Redmine::Installer::Exec.new(command, title, with_timer).repeatable_run
#       end
#     end

#     class Rake < Base
#       command 'bundle exec rake'
#       add 'db_create',  'db:create'
#       add 'db_migrate', 'db:migrate'
#       add 'generate_secret_token', 'generate_secret_token'
#       add 'redmine_plugin_migrate', 'redmine:plugins:migrate'
#       add 'production', 'RAILS_ENV=production'
#     end

#     class Bundle < Base
#       command 'bundle'
#       add 'install', 'install'
#       add 'production', '--without development test'
#     end
#   end
# end
