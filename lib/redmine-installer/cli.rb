require 'gli'

module Redmine::Installer
  class CLI
    extend GLI::App

    def self.spec
      @spec ||= Gem::Specification::load('redmine-installer.gemspec')
    end

    def self.start(argv)
      program_desc spec.summary
      version Redmine::Installer::VERSION

      desc "Show verbose output"
      default_value false
      switch [:d, :debug], negatable: false

      # pre do |global_options, command, options, args|
      #   $verbose = global_options[:debug]
      # end

      desc "Install redmine from package"
      arg :redmine
      command [:i, :install] do |c|
        c.action do |global_options, options, args|
          r_installer = Redmine::Installer::Install.new(args.first, global_options.merge(options))
          r_installer.run
        end
      end

      desc "Upgrade redmine from package"
      arg :package
      arg :redmine_root
      command [:u, :upgrade] do |c|
        c.action do |global_options, options, args|
          r_upgrader = Redmine::Installer::Upgrade.new(args.first, global_options.merge(options))
          r_upgrader.run
        end
      end

      run(argv)
    end

  end
end
