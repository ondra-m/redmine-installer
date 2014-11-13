require 'singleton'

module Redmine::Installer
  class Command
    include Singleton
    include Redmine::Installer::Utils

    RAKE = 'bundle exec rake'

    def bundle_install(env)
      run('bundle install', get_bundle_env(env), :'command.bundle_install')
    end

    def rake_db_create(env)
      run(RAKE, 'db:create', get_rails_env(env), :'command.rake_db_create')
    end

    def rake_db_migrate(env)
      run(RAKE, 'db:migrate', get_rails_env(env), :'command.rake_db_migrate')
    end

    def rake_redmine_plugin_migrate(env)
      run(RAKE, 'redmine:plugins:migrate', get_rails_env(env), :'command.rake_redmine_plugin_migrate')
    end

    def rake_generate_secret_token(env)
      run(RAKE, 'generate_secret_token', get_rails_env(env), :'command.rake_generate_secret_token')
    end

    private

      def run(*args)
        _args = args.dup

        # Last element is title
        title = args.pop
        title = translate(title) if title.is_a?(Symbol)
        title = "--> <yellow>#{title}</yellow>"
        colorize(title)

        command = args.join(' ')

        puts '-->'
        puts title
        puts '-->'
        success = Kernel.system(command)

        unless success
          if confirm(:do_you_want_repeat_command, false)
            return run(*_args)
          end
        end

        return success
      end

      def get_rails_env(env)
        if    env.include?('production');  'RAILS_ENV=production'
        elsif env.include?('development'); 'RAILS_ENV=development'
        elsif env.include?('test');        'RAILS_ENV=test'
        else
          ''
        end
      end

      def get_bundle_env(env)
        if env.include?('production')
          '--without development test'
        else
          ''
        end
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
