module Redmine::Installer::Step
  class WebserverConfig < Base

    def up
      choices = {}
      plugin::WebServer.all.each do |m|
        choices[m] = m.title
      end
      choices[nil] = t(:skip)

      answer = choose(:"what_web_server_do_you_want", choices, default: nil)

      # Skip
      return if answer.nil?

      instance = answer.new

      say("(#{instance.class.title})", 2)

      puts '============================================== ', 2
      say  answer.generate_config(base.redmine_root)
      puts # new line
      puts '============================================== ', 2
    end

  end
end
