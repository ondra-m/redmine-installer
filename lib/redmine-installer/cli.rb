require 'gli'

module Redmine::Installer
  class CLI
    extend GLI::App

    def self.spec
      @spec ||= Gem::Specification::load('redmine-installer.gemspec')
    end

    def self.start(argv)
      # Program settings
      program_desc I18n.translate(:redmine_installer_summary)
      version Redmine::Installer::VERSION

      # Global options

      # Verbose
      desc I18n.translate(:cli_show_verbose_output)
      default_value false
      switch [:d, :v, :debug, :verbose], negatable: false

      # Locale
      default_value 'en'
      flag [:l, :locale]

      # Before all action
      pre do |global_options, command, options, args|
        $verbose = global_options[:debug]
        I18n.locale = global_options[:locale]
        true
      end

      # Install command
      desc I18n.translate(:cli_install_desc)
      arg :package
      command [:i, :install] do |c|
        c.flag [:s, :source], default_value: 'file',
                              must_match: ['file', 'git'],
                              desc: I18n.translate(:cli_flag_source)

        c.flag [:b, :branch], default_value: 'master',
                              desc: I18n.translate(:cli_flag_branch)

        c.flag [:e, :env, :environment], default_value: ['production'],
                                         desc: I18n.translate(:cli_flag_environment),
                                         type: Array

        c.action do |global_options, options, args|
          run_action('install', args.first, options)
        end
      end

      # Upgrade command
      desc I18n.translate(:cli_upgrade_desc)
      arg :package
      command [:u, :upgrade] do |c|
        c.flag [:p, :profile]
        c.flag [:s, :source], default_value: 'file',
                              must_match: ['file', 'git'],
                              desc: I18n.translate(:cli_flag_source)

        c.flag [:e, :env, :environment], default_value: ['production'],
                                         desc: I18n.translate(:cli_flag_environment),
                                         type: Array

        c.switch 'skip-old-modifications', default_value: false

        c.action do |global_options, options, args|
          run_action('upgrade', args.first, options)
        end
      end

      # Backup command
      desc I18n.translate(:cli_backup_desc)
      arg :redmine_root
      command [:b, :backup] do |c|
        c.flag [:p, :profile]
        c.action do |global_options, options, args|
          run_action('backup', args.first, options)
        end
      end

      run(argv)
    end

    def self.run_action(action, *args)
      Redmine::Installer.const_get(action.capitalize).new(*args).run
    end

  end
end
