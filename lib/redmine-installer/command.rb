module Redmine::Installer
  class Command
    RAKE_DB_CREATE = 'bundle exec rake db:create RAILS_ENV=production'
    RAKE_DB_MIGRATE = 'bundle exec rake db:migrate RAILS_ENV=production'
    RAKE_GENERATE_SECRET_TOKEN = 'bundle exec rake generate_secret_token RAILS_ENV=production'
    RAKE_REDMINE_PLUGIN_MIGRATE = 'bundle exec rake redmine_plugin_migrate RAILS_ENV=production'
    BUNDLE_INSTALL = 'bundle install --without development test'
  end
end
